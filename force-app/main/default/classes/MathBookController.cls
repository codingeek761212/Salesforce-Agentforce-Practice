public with sharing class MathBookController {
    
    @AuraEnabled
    public static List<MathBook> getAllMathBooks(){
        try {
            List<APS_Math_Books__c> mathBooks = [select Id, Name, Book_Name__c, Contents__c, Author_Name__c, Price__c from APS_Math_Books__c ];
            List<MathBook> mathBooksToReturn = new List<MathBook>();
            for(APS_Math_Books__c book : mathBooks)
            {
                MathBook tempBook = new MathBook();
                tempBook.Id = book.Id;
                tempBook.Name = book.Name;
                tempBook.BookName = book.Book_Name__c;
                tempBook.Contents = book.Contents__c;
                tempBook.AuthorName = book.Author_Name__c;
                tempBook.Price = book.Price__c;
                mathBooksToReturn.add(tempBook);
            }
            return mathBooksToReturn;
            
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class MathBook
    {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String BookName;
        @AuraEnabled public String Contents;
        @AuraEnabled public String AuthorName;
        @AuraEnabled public Decimal Price;
    }
}