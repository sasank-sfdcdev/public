/**
 * @File Name          : pocTable.js
 * @Description        : 
 * @Author             : Sasank Subrahmanyam V
 * @Group              : 
 * @Last Modified By   : Sasank Subrahmanyam V
 * @Last Modified On   : 8/2/2019, 3:35:49 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/1/2019, 11:20:30 AM   Sasank Subrahmanyam V     Initial Version
**/
import { LightningElement, track } from 'lwc';

export default class PocTable extends LightningElement {
	config = {
		height: "12rem",
		objectName: "Account",
		tableConfig: {
			columns: [
				{ api: 'Name', label: 'Name', fieldName: 'Name', sortable: true },
				{ api: 'CreatedDate', label: 'Created On', fieldName: 'CreatedDate', type: 'date', sortable: true },
				{ api: 'CreatedBy.Name', label: 'Created By', fieldName: 'CreatedByName', sortable: true }
			]
		}
	};
}