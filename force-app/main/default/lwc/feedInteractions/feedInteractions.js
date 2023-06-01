import { LightningElement, api, wire } from 'lwc';
import getCaseMessages from '@salesforce/apex/ConversationController.getCaseMessages';

export default class FeedInteractions extends LightningElement {
	@api recordId;
	feedItems;

	@wire(getCaseMessages, { caseId: '$recordId' })
	wiredMessages({ error, data }) {
		if (data) {
			this.feedItems = data;
		} else if (error) {
			console.error(error);
		}
	}	
	
}