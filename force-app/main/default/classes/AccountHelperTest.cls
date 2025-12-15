@isTest
private class AccountHelperTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account ' + i,
                AnnualRevenue = 100000 * i
            ));
        }
        insert testAccounts;
        
        // Create test Opportunities
        List<Opportunity> testOpps = new List<Opportunity>();
        for (Account acc : testAccounts) {
            testOpps.add(new Opportunity(
                Name = 'Test Opp for ' + acc.Name,
                AccountId = acc.Id,
                Amount = 50000,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            ));
        }
        insert testOpps;
    }
    
    @isTest
    static void testUpdateAnnualRevenue_WithValidAccounts() {
        // Arrange
        List<Account> accounts = [SELECT Id, AnnualRevenue FROM Account LIMIT 5];
        for (Account acc : accounts) {
            acc.AnnualRevenue = null;
        }
        
        // Act
        Test.startTest();
        AccountHelper.updateAnnualRevenue(accounts);
        Test.stopTest();
        
        // Assert
        List<Account> updatedAccounts = [SELECT Id, AnnualRevenue FROM Account];
        for (Account acc : updatedAccounts) {
            System.assertEquals(0, acc.AnnualRevenue, 
                'Annual Revenue should be set to 0 for null values');
        }
    }
    
    @isTest
    static void testUpdateAnnualRevenue_WithNullList() {
        // Act
        Test.startTest();
        AccountHelper.updateAnnualRevenue(null);
        Test.stopTest();
        
        // Assert - No exception should be thrown
        System.assert(true, 'Method should handle null input gracefully');
    }
    
    @isTest
    static void testUpdateAnnualRevenue_WithEmptyList() {
        // Act
        Test.startTest();
        AccountHelper.updateAnnualRevenue(new List<Account>());
        Test.stopTest();
        
        // Assert - No exception should be thrown
        System.assert(true, 'Method should handle empty list gracefully');
    }
    
    @isTest
    static void testGetAccountsWithOpportunities_ValidIds() {
        // Arrange
        List<Account> accounts = [SELECT Id FROM Account LIMIT 3];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        // Act
        Test.startTest();
        List<Account> result = AccountHelper.getAccountsWithOpportunities(accountIds);
        Test.stopTest();
        
        // Assert
        System.assertEquals(3, result.size(), 'Should return 3 accounts');
        for (Account acc : result) {
            System.assertNotEquals(null, acc.Opportunities, 
                'Opportunities should be queried');
        }
    }
    
    @isTest
    static void testGetAccountsWithOpportunities_NullInput() {
        // Act
        Test.startTest();
        List<Account> result = AccountHelper.getAccountsWithOpportunities(null);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, result.size(), 
            'Should return empty list for null input');
    }
    
    @isTest
    static void testCalculateTotalOpportunityAmount_ValidAccount() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Act
        Test.startTest();
        Decimal totalAmount = AccountHelper.calculateTotalOpportunityAmount(testAccount.Id);
        Test.stopTest();
        
        // Assert
        System.assertEquals(50000, totalAmount, 
            'Total amount should equal the opportunity amount');
    }
    
    @isTest
    static void testCalculateTotalOpportunityAmount_NullInput() {
        // Act
        Test.startTest();
        Decimal totalAmount = AccountHelper.calculateTotalOpportunityAmount(null);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, totalAmount, 
            'Should return 0 for null account ID');
    }
    
    @isTest
    static void testBulkProcessing() {
        // Arrange - Create 200 accounts to test bulk processing
        List<Account> bulkAccounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            bulkAccounts.add(new Account(
                Name = 'Bulk Test Account ' + i
            ));
        }
        insert bulkAccounts;
        
        // Act
        Test.startTest();
        AccountHelper.updateAnnualRevenue(bulkAccounts);
        Test.stopTest();
        
        // Assert
        List<Account> updatedAccounts = [
            SELECT Id, AnnualRevenue 
            FROM Account 
            WHERE Name LIKE 'Bulk Test Account%'
        ];
        System.assertEquals(200, updatedAccounts.size(), 
            'All 200 accounts should be processed');
        for (Account acc : updatedAccounts) {
            System.assertEquals(0, acc.AnnualRevenue, 
                'All accounts should have AnnualRevenue set to 0');
        }
    }
}