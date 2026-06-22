public class APS_GetMathBooksResponse 
{
    public class MathBookResponse
    {
        @InvocableVariable
        Public String Id;
        @InvocableVariable
        Public String BookName;
        @InvocableVariable
        Public String AuthorName;
        @InvocableVariable
        Public String Contents;
        @InvocableVariable
        Public Decimal Price;
        @InvocableVariable
        Public String TypeOfBook;
    }
    
    public class MathBookRequest
    {
        @InvocableVariable
        public String requestId;
    }
    
    @InvocableMethod(label = 'Get All Math Books')
    public static List<MathBookResponse> getMathBooks(List<MathBookRequest> requests)
    {
        List<MathBookResponse> mathBooksResponse = new List<MathBookResponse>();
        try{
            List<APS_Math_Books__c> listOfBooks = [Select Id, Book_Name__c, Contents__c, Price__c, Author_Name__c, RecordTypeId, RecordType.Name from APS_Math_Books__c];
            for(APS_Math_Books__c book : listOfBooks)
            {
                MathBookResponse mathBook = new MathBookResponse();
                mathBook.Id = book.Id;
                mathBook.BookName = book.Book_Name__c;
                mathBook.AuthorName = book.Author_Name__c;
                mathBook.Contents = book.Contents__c;
                mathBook.Price = book.Price__c;
                mathBook.TypeOfBook = book.RecordType.Name;
                mathBooksResponse.add(mathBook);
            }
            system.debug('List of math books: '+ mathBooksResponse);
            
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
        }
        return mathBooksResponse;
    }

}