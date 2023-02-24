# public
Generic components

Currently there are 2 generic components (PFB). Very soon I will add DEMO components which will show how to use them.

1. datatable: Generic datatable which uses standard lightning-datatable for showing records in table <br/>
     1. Gets data from database automatically. Can use relationship fields also. <br/>
     * This fork adds support for sorting by related fields <br/>
     2. Sort functionality <br/>
     3. Pagination - first, previous, next and last pages <br/>
     4. Persistant selection of records across pages. getSelectedRows public method to get selected data. <br/>
     5. All events of lightning-datatable plus event while loading data <br/>
     6. Cacheable data <br/>
     7. Sosl search <br/>
     8. Dynamically change data filters <br/>

2. upload: Currently implemented only for admins (without shareable)  <br/>
    1. Use component in create form wherein, the file has to be uploaded before record (like account or case etc) is created. <br/>
    2. Share records with other users <br/>
    3. Search for files <br/>
    4. Delete files <br/>
    5. Used datatable for showing records which gives all the functionality like sort, pagination etc <br/>
    
     
