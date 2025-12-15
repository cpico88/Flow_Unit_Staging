public with sharing class AccountHelper {
    
    /**
     * Updates the Annual Revenue for a list of Accounts
     * Bulkified to handle multiple records efficiently
     * @param accounts List of Account records to update
     */
    public static void updateAnnualRevenue(List<Account> accounts) {
        if (accounts == null || accounts.isEmpty()) {
            return;
        }
        
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : accounts) {
            if (acc.AnnualRevenue == null) {
                acc.AnnualRevenue = 0;
            }
            accountsToUpdate.add(acc);
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    /**
     * Retrieves Accounts with Opportunities
     * Uses selective SOQL query with indexed field
     * @param accountIds Set of Account IDs to query
     * @return List of Accounts with related Opportunities
     */
    public static List<Account> getAccountsWithOpportunities(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return new List<Account>();
        }
        
        return [
            SELECT Id, Name, AnnualRevenue, 
                   (SELECT Id, Name, Amount, StageName FROM Opportunities)
            FROM Account
            WHERE Id IN :accountIds
            LIMIT 200
        ];
    }
    
    /**
     * Calculates total opportunity amount for an Account
     * @param accountId The Account ID
     * @return Total amount of all Opportunities
     */
    public static Decimal calculateTotalOpportunityAmount(Id accountId) {
        if (accountId == null) {
            return 0;
        }
        
        Decimal totalAmount = 0;
        
        for (Opportunity opp : [
            SELECT Amount 
            FROM Opportunity 
            WHERE AccountId = :accountId 
            AND Amount != null
        ]) {
            totalAmount += opp.Amount;
        }
        
        return totalAmount;
    }
}