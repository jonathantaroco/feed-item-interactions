@isTest
public class ConversationCtrlTest {
	
	@isTest
	static void testGetCaseMessages() {
		Case testCase = new Case();
		insert testCase;
		
		EmailMessage testEmail1 = new EmailMessage(
			ParentId = testCase.Id,
			Subject = 'Test email 1',
			TextBody = 'This is a test email'
		);
		
		EmailMessage testEmail2 = new EmailMessage(
			ParentId = testCase.Id,
			Subject = 'Test email 2',
			TextBody = 'This is another test email'
		);

		insert new List<EmailMessage>{testEmail1, testEmail2};
		
		FeedItem testFeedItem1 = new FeedItem(
			ParentId = testCase.Id,
			Body = 'This is a test feed item',
			Type = 'TextPost'
		);
		
		FeedItem testFeedItem2 = new FeedItem(
			ParentId = testCase.Id,
			Body = 'This is another test feed item',
			Type = 'ContentPost'
		);

		insert new List<FeedItem>{testFeedItem1, testFeedItem2};
		
		Test.startTest();
			List<ConversationController.Message> messages = ConversationController.getCaseMessages(testCase.Id);
		Test.stopTest();
		
		System.assertEquals(4, messages.size());
	}
}