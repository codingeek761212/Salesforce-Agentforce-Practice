/**
 * @description Invocable action for the Employee Agent that retrieves all Tasks and Cases
 * for a specific Account (identified by accountId) with a due date of TODAY, and returns
 * them as a formatted TOON (Text Output Organized as Narrative) string.
 * - Tasks are filtered by AccountId + ActivityDate = TODAY.
 * - Cases are filtered by AccountId + ClosedDate = TODAY (closest standard date equivalent).
 *   Update the WHERE clause to a custom Due_Date__c field if your org uses one.
 * Callable from Agentforce Agent Actions, Flows, and Process Builder.
 */
public with sharing class GetAllTasksAndCasesForAgent {

    // ─── Constants ────────────────────────────────────────────────────────────

    private static final String DIVIDER   = '-----------------------------------------';
    private static final String NEWLINE   = '\n';
    private static final String NOT_AVAIL = 'N/A';

    // ─── Invocable Method ─────────────────────────────────────────────────────

    /**
     * @description Retrieves Tasks (ActivityDate = TODAY) and Cases (ClosedDate = TODAY)
     * for the Account specified in each Request, then formats and returns the results as
     * a TOON string for the Employee Agent.
     * Both queries are executed once outside the request loop for governor-limit safety,
     * keyed by AccountId so each request can look up its own results.
     * @param requests List of Request inputs — each must supply a valid accountId
     * @return List of Response outputs containing the formatted TOON summary or error details
     * @example
     * GetAllTasksAndCasesForAgent.Request req = new GetAllTasksAndCasesForAgent.Request();
     * req.accountId = '001XXXXXXXXXXXX';
     * List<GetAllTasksAndCasesForAgent.Response> results =
     *     GetAllTasksAndCasesForAgent.execute(new List<GetAllTasksAndCasesForAgent.Request>{ req });
     * System.debug(results[0].summary);
     */
    @InvocableMethod(
        label='Get Tasks and Cases for Account Due Today'
        description='Retrieves all Tasks and Cases for a specific Account that are due today, and returns a formatted list for the Employee Agent.'
        category='Employee Agent'
        callout=false
    )
    public static List<Response> execute(List<Request> requests) {
        List<Response> responses = new List<Response>();

        // Collect unique account IDs for bulkified queries
        Set<Id> accountIds = new Set<Id>();
        for (Request req : requests) {
            if (String.isNotBlank(req.accountId)) {
                accountIds.add((Id) req.accountId);
            }
        }

        // Execute both queries once outside the loop — bulkification safeguard
        Map<Id, List<Task>> tasksByAccount = queryTasksByAccountIds(accountIds);
        Map<Id, List<Case>> casesByAccount = queryCasesByAccountIds(accountIds);

        // Query account names for display in the TOON header
        Map<Id, String> accountNames = new Map<Id, String>();
        for (Account acc : [
            SELECT Id, Name FROM Account WHERE Id IN :accountIds WITH USER_MODE
        ]) {
            accountNames.put(acc.Id, acc.Name);
        }

        for (Request req : requests) {
            Response res = new Response();
            try {
                if (String.isBlank(req.accountId)) {
                    throw new IllegalArgumentException('accountId is required and must not be blank.');
                }
                Id accId = (Id) req.accountId;
                String accName = accountNames.containsKey(accId) ? accountNames.get(accId) : req.accountId;
                List<Task> tasks = tasksByAccount.containsKey(accId) ? tasksByAccount.get(accId) : new List<Task>();
                List<Case> cases = casesByAccount.containsKey(accId) ? casesByAccount.get(accId) : new List<Case>();
                res.summary   = buildToonString(tasks, cases, accName);
                res.isSuccess = true;
            } catch (Exception ex) {
                res.isSuccess    = false;
                res.errorMessage = ex.getMessage();
                res.errorType    = ex.getTypeName();
                res.summary      = 'Unable to retrieve data. Please contact your administrator.';
            }
            responses.add(res);
        }
		system.debug('Responses: '+responses);
        return responses;
    }

    // ─── Private Helpers ──────────────────────────────────────────────────────

    /**
     * @description Queries Tasks where ActivityDate (Due Date) equals today for the given Account IDs.
     * Results are grouped into a Map keyed by AccountId for per-request lookup.
     * @param accountIds Set of Account IDs to filter by
     * @return Map of AccountId to List<Task> records due today for that account
     */
    private static Map<Id, List<Task>> queryTasksByAccountIds(Set<Id> accountIds) {
        Map<Id, List<Task>> result = new Map<Id, List<Task>>();
        for (Task t : [
            SELECT Id, Subject, Status, Priority, ActivityDate,
                   Owner.Name, What.Name, Who.Name, Description, AccountId
            FROM Task
            WHERE AccountId IN :accountIds
              AND ActivityDate = TODAY
            WITH USER_MODE
            ORDER BY Priority DESC, Subject ASC
        ]) {
            if (!result.containsKey(t.AccountId)) {
                result.put(t.AccountId, new List<Task>());
            }
            result.get(t.AccountId).add(t);
        }
        return result;
    }

    /**
     * @description Queries Cases where ClosedDate equals today for the given Account IDs.
     * ClosedDate is used as the standard due-date equivalent for Case.
     * To use a custom Due Date field, replace "ClosedDate = TODAY"
     * with "Due_Date__c = TODAY" (or your org-specific field API name).
     * Results are grouped into a Map keyed by AccountId for per-request lookup.
     * @param accountIds Set of Account IDs to filter by
     * @return Map of AccountId to List<Case> records due today for that account
     */
    private static Map<Id, List<Case>> queryCasesByAccountIds(Set<Id> accountIds) {
        Map<Id, List<Case>> result = new Map<Id, List<Case>>();
        for (Case c : [
            SELECT Id, CaseNumber, Subject, Status, Priority, ClosedDate,
                   Owner.Name, Account.Name, AccountId, Description, Origin, Type
            FROM Case
            WHERE AccountId IN :accountIds
              AND DAY_ONLY(Due_Date__c) = TODAY
            ORDER BY Priority DESC, CaseNumber ASC
        ]) {
            if (!result.containsKey(c.AccountId)) {
                result.put(c.AccountId, new List<Case>());
            }
            result.get(c.AccountId).add(c);
        }
        return result;
    }

    /**
     * @description Assembles a TOON-formatted string from the provided Tasks and Cases lists
     * for the specified account name.
     * Uses a List<String> joined at the end to avoid repeated string concatenation in loops.
     * @param tasks    List of Task records due today for this account
     * @param cases    List of Case records due today for this account
     * @param accName  Account name (or ID) to display in the report header
     * @return A human-readable TOON string formatted as a two-section list
     */
    private static String buildToonString(List<Task> tasks, List<Case> cases, String accName) {
        List<String> lines = new List<String>();

        // ── Header ──────────────────────────────────────────────────────────
        lines.add('TASKS & CASES DUE TODAY - ' + Date.today().format());
        lines.add('Account: ' + accName);
        lines.add(DIVIDER);

        // ── Tasks Section ────────────────────────────────────────────────────
        lines.add('');
        lines.add('TASKS DUE TODAY (' + tasks.size() + ')');
        lines.add(DIVIDER);

        if (tasks.isEmpty()) {
            lines.add('  No tasks due today for this account.');
        } else {
            Integer taskIdx = 1;
            for (Task t : tasks) {
                lines.add(taskIdx + '. Subject   : ' + (String.isNotBlank(t.Subject)   ? t.Subject      : NOT_AVAIL));
                lines.add('   Status    : ' + (String.isNotBlank(t.Status)             ? t.Status       : NOT_AVAIL));
                lines.add('   Priority  : ' + (String.isNotBlank(t.Priority)           ? t.Priority     : NOT_AVAIL));
                lines.add('   Owner     : ' + (t.Owner   != null                       ? t.Owner.Name   : NOT_AVAIL));
                lines.add('   Related To: ' + (t.What    != null                       ? t.What.Name    : NOT_AVAIL));
                lines.add('   Who       : ' + (t.Who     != null                       ? t.Who.Name     : NOT_AVAIL));
                if (String.isNotBlank(t.Description)) {
                    lines.add('   Notes     : ' + t.Description);
                }
                lines.add('');
                taskIdx++;
            }
        }

        // ── Cases Section ─────────────────────────────────────────────────────
        lines.add('CASES DUE TODAY (' + cases.size() + ')');
        lines.add(DIVIDER);

        if (cases.isEmpty()) {
            lines.add('  No cases due today for this account.');
        } else {
            Integer caseIdx = 1;
            for (Case c : cases) {
                lines.add(caseIdx + '. Case #    : ' + (String.isNotBlank(c.CaseNumber) ? c.CaseNumber    : NOT_AVAIL));
                lines.add('   Subject   : ' + (String.isNotBlank(c.Subject)             ? c.Subject       : NOT_AVAIL));
                lines.add('   Status    : ' + (String.isNotBlank(c.Status)              ? c.Status        : NOT_AVAIL));
                lines.add('   Priority  : ' + (String.isNotBlank(c.Priority)            ? c.Priority      : NOT_AVAIL));
                lines.add('   Account   : ' + (c.Account != null                        ? c.Account.Name  : NOT_AVAIL));
                lines.add('   Owner     : ' + (c.Owner   != null                        ? c.Owner.Name    : NOT_AVAIL));
                lines.add('   Origin    : ' + (String.isNotBlank(c.Origin)              ? c.Origin        : NOT_AVAIL));
                lines.add('   Type      : ' + (String.isNotBlank(c.Type)                ? c.Type          : NOT_AVAIL));
                if (String.isNotBlank(c.Description)) {
                    lines.add('   Notes     : ' + c.Description);
                }
                lines.add('');
                caseIdx++;
            }
        }

        lines.add(DIVIDER);
        lines.add('End of Report');

        return String.join(lines, NEWLINE);
    }

    // ─── Request / Response DTOs ──────────────────────────────────────────────

    /**
     * @description Input parameters from the calling Agent or Flow.
     * accountId is required — the action filters all records to this specific Account.
     */
    public class Request {
        @InvocableVariable(
            label='Account ID'
            description='The Salesforce ID of the Account whose Tasks and Cases due today should be retrieved.'
            required=true
        )
        public String accountId;
    }

    /**
     * @description Output results returned to the calling Agent or Flow.
     */
    public class Response {
        @InvocableVariable(
            label='Tasks and Cases Summary'
            description='Formatted TOON string listing all Tasks and Cases for the specified Account with a due date of today.'
        )
        public String summary;

        @InvocableVariable(
            label='Is Successful'
            description='True when the action completed without errors.'
        )
        public Boolean isSuccess;

        @InvocableVariable(
            label='Error Message'
            description='Human-readable error detail when isSuccess is false.'
        )
        public String errorMessage;

        @InvocableVariable(
            label='Error Type'
            description='Exception class name when isSuccess is false.'
        )
        public String errorType;
    }
}