public class APS_GetMathBooksResponses
{
    public class MathBookResponse
    {
        @InvocableVariable
        Public String response;
    }
    
    public class MathBookRequest
    {
        @InvocableVariable
        public String requestId;
    }
    
    @InvocableMethod(label = 'Show all Math Books')
    public static List<MathBookResponse> getMathBooks(List<MathBookRequest> requests)
    {
        List<MathBookResponse> mathBooksResponse = new List<MathBookResponse>();
        try{
            List<APS_Math_Books__c> listOfBooks = [Select Id, Book_Name__c, Contents__c, Price__c, Author_Name__c, RecordTypeId, RecordType.Name from APS_Math_Books__c];
            Map<String, APS_Math_Books__c> mapOfBooks = new Map<String, APS_Math_Books__c>();
            for(APS_Math_Books__c book : listOfBooks)
            {
                mapOfBooks.put(book.Id, book);
            }
            MathBookResponse bookResponse = new MathBookResponse();
            bookResponse.response = JSON.serialize(mapOfBooks);
            mathBooksResponse.add(bookResponse);
            system.debug('List of math books: '+ mathBooksResponse);
            
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
        }
        return mathBooksResponse;
    }

}