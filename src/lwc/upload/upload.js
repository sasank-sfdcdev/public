/**
 * @File Name          : upload.js
 * @Description        : 
 * @Author             : Sasank Subrahmanyam V
 * @Group              : 
 * @Last Modified By   : Sasank Subrahmanyam V
 * @Last Modified On   : 8/3/2019, 4:10:04 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    5/18/2019, 12:31:12 AM   Sasank Subrahmanyam V     Initial Version
 **/
import { LightningElement, api, track } from 'lwc';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createDocumentLinks from '@salesforce/apex/uploadController.createDocumentLink';
import getDocumentLinks from '@salesforce/apex/uploadController.getDocumentLinks';
import deleteDocuments from '@salesforce/apex/uploadController.deleteDocuments';

export default class Upload extends LightningElement {
	@api label;
	@api multiple;
	@api accept;
	@api parentId;

	@track queryFilters = "";

	files = [];

	@track documentsConfig = {
		objectName: "ContentDocument",
		tableConfig: {
			columns: [
				{ api: 'Title', label: 'Title', fieldName: 'Title', sortable: true },
				{ api: 'ContentSize', label: 'Size (bytes)', fieldName: 'ContentSize', type: 'number', sortable: true, callAttributes: { alignment: 'left' } },
				{ api: 'FileType', label: 'File Type', fieldName: 'FileType', sortable: true },
				{ api: 'Owner.Name', label: 'Owner', fieldName: 'OwnerName', sortable: true },
				{ label: '#', type: 'button-icon', typeAttributes: { name: 'delete', iconName: 'utility:delete', variant: 'bare' } }
			],
			hideCheckboxColumn: true
		},
		sortBy: 'CreatedDate',
		queryFilters: (this.parentId ? (` ParentId='${this.parentId}' `) : ''),
		pageSize: '5',
		limit: '100'
	};

	connectedCallback() {
		this.uploadToId = this.parentId || userId;
	}

	handleRowAction = event => {
		console.log(JSON.stringify(event.detail));
		this.template.querySelector("[data-id=spinner]").classList.remove('slds-hide');
		deleteDocuments({ docIds: [event.detail.row.Id] })
			.then(response => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Success',
						message: 'Successfully deleted!',
						variant: 'success'
					})
				);
				this.template.querySelector("[data-id=spinner]").classList.add('slds-hide');
				this.template.querySelector('c-datatable[data-id=documents]').refresh();
			})
			.catch(error => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Error',
						message: error,
						variant: 'error'
					})
				);
				this.template.querySelector("[data-id=spinner]").classList.add('slds-hide');
			});
	}

	@api
	uploadToRecord(recordId) {
		const params = {
			files: this.files,
			recordId: recordId
		};

		createDocumentLinks({
			params: params
		})
			.then(() => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Success',
						message: 'File(s) shared',
						variant: 'success'
					})
				);
			})
			.catch((error) => {
				this.message = 'Error received: code' + error.errorCode + ', ' + 'message ' + error.body.message;
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Error uploading file(s)',
						message: this.message,
						variant: 'error'
					})
				);
			});
	}

	shareFiles() {
		this.files = [];
		let selectedDocsMap = this.template.querySelector("c-datatable[data-id=documents]").getSelectedData();
		Object.values(selectedDocsMap).forEach(doc => {
			this.files.push({ documentId: doc.Id, name: doc.Title });
		});
		console.log("Files List => ", JSON.stringify(this.files));
		this.uploadToRecord(this.template.querySelector(".id-share-record").value);
	}

	searchFiles(event) {
		if (event.keyCode === 13) {
			this.doSearch();
		}
	}

	doSearch() {
		this.queryFilters = (this.parentId ? (` ParentId='${this.parentId}' AND `) : '') +
			"Title LIKE '%" + this.template.querySelector(".id-search-str").value + "%'";
	}

	handleUploadFinished(event) {
		this.files = event.detail.files;
		this.refreshSearchData();
		this.files.forEach((file) => {
			console.log('Uploaded => ', file.documentId, file.name);
		});
	}

	refreshSearchData() {
		if (this.template.querySelector("c-datatable[data-id=documents]")) {
			this.template.querySelector("c-datatable[data-id=documents]").refresh();
		}
	}
}