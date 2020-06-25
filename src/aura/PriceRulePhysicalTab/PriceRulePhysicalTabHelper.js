({ // eslint-disable-line
    originalData: [
        {
            "name": "123555",
            "accountName": "Rewis Inc",
            "employees": 3100,
            "phone": "837-555-1212",
            "accountOwner": "http://example.com/jane-doe",
            "accountOwnerName": "Jane Doe",
            "billingCity": "Phoeniz, AZ"
        },

        {
            "name": "123556",
            "accountName": "Acme Corporation",
            "employees": 10000,
            "phone": "837-555-1212",
            "accountOwner": "http://example.com/john-doe",
            "accountOwnerName": "John Doe",
            "billingCity": "San Francisco, CA",
            "_children": [
                {
                    "name": "123556-A",
                    "accountName": "Acme Corporation (Bay Area)",
                    "employees": 3000,
                    "phone": "837-555-1212",
                    "accountOwner": "http://example.com/john-doe",
                    "accountOwnerName": "John Doe",
                    "billingCity": "New York, NY",
                    "_children": []
                },

                {
                    "name": "123556-B",
                    "accountName": "Acme Corporation (East)",
                    "employees": 430,
                    "phone": "837-555-1212",
                    "accountOwner": "http://example.com/john-doe",
                    "accountOwnerName": "John Doe",
                    "billingCity": "San Francisco, CA",
                    "_children": [
                        {
                            "name": "123556-B-A",
                            "accountName": "Acme Corporation (NY)",
                            "employees": 1210,
                            "phone": "837-555-1212",
                            "accountOwner": "http://example.com/jane-doe",
                            "accountOwnerName": "Jane Doe",
                            "billingCity": "New York, NY"
                        },
                        {
                            "name": "123556-B-B",
                            "accountName": "Acme Corporation (VA)",
                            "employees": 410,
                            "phone": "837-555-1212",
                            "accountOwner": "http://example.com/john-doe",
                            "accountOwnerName": "John Doe",
                            "billingCity": "New York, NY",
                            "_children": []
                        }
                    ]
                }
            ]
        },

        {
            "name": "123557",
            "accountName": "Rhode Enterprises",
            "employees": 6000,
            "phone": "837-555-1212",
            "accountOwner": "http://example.com/john-doe",
            "accountOwnerName": "John Doe",
            "billingCity": "New York, NY",
            "_children": [
                {
                    "name": "123557-A",
                    "accountName": "Rhode Enterprises (UCA)",
                    "employees": 2540,
                    "phone": "837-555-1212",
                    "accountOwner": "http://example.com/john-doe",
                    "accountOwnerName": "John Doe",
                    "billingCity": "New York, NY"
                }
            ]
        },

        {
            "name": "123558",
            "accountName": "Tech Labs",
            "employees": 1856,
            "phone": "837-555-1212",
            "accountOwner": "http://example.com/john-doe",
            "accountOwnerName": "John Doe",
            "billingCity": "New York, NY",
            "_children": [
                {
                    "name": "123558-A",
                    "accountName": "Opportunity Resources Inc",
                    "employees": 1934,
                    "phone": "837-555-1212",
                    "accountOwner": "http://example.com/john-doe",
                    "accountOwnerName": "John Doe",
                    "billingCity": "Los Angeles, CA"
                }
            ]
        }
    ],

    childrenData: {
        "123556-A": [
            {
                "name": "123556-A-A",
                "accountName": "Acme Corporation (Oakland)",
                "employees": 745,
                "phone": "837-555-1212",
                "accountOwner": "http://example.com/john-doe",
                "accountOwnerName": "John Doe",
                "billingCity": "New York, NY"
            },
            {
                "name": "123556-A-B",
                "accountName": "Acme Corporation (San Francisco)",
                "employees": 578,
                "phone": "837-555-1212",
                "accountOwner": "http://example.com/jane-doe",
                "accountOwnerName": "Jane Doe",
                "billingCity": "Los Angeles, CA"
            }
        ],

        "123556-B-B": [
            {
                "name": "123556-B-B-A",
                "accountName": "Allied Technologies",
                "employees": 390,
                "phone": "837-555-1212",
                "accountOwner": "http://example.com/jane-doe",
                "accountOwnerName": "Jane Doe",
                "billingCity": "Los Angeles, CA",
                "_children": [
                    {
                        "name": "123556-B-B-A-A",
                        "accountName": "Allied Technologies (UV)",
                        "employees": 270,
                        "phone": "837-555-1212",
                        "accountOwner": "http://example.com/john-doe",
                        "accountOwnerName": "John Doe",
                        "billingCity": "San Francisco, CA"
                    }
                ]
            }
        ]
    },

    addChildrenToRow: function(data, rowName, children) {
        var that = this;
        // step through the array using recursion until we find the correct row to update
        var newData = data.map(function(row) {
            // does this row have a properly formatted _children key with content?
            var hasChildrenContent = false;
            if (row.hasOwnProperty('_children') && Array.isArray(row._children) && row._children.length > 0) {
                hasChildrenContent = true;
            }
			if (row.id == rowName) {
                row._children = children;
            } else if (hasChildrenContent) {
                that.addChildrenToRow(row._children, rowName, children);
            }
			return row;
        });
		return newData;
    },

    retrieveUpdatedData: function(gridData,rowName,controllerResponse) {
        var that = this;
		
        return new Promise(function (resolve, reject) {
            // mimic server delay
            window.setTimeout(
                function() {
                    // add children to data
                    var updatedData = that.addChildrenToRow(gridData, rowName, controllerResponse[rowName]);

                    resolve(updatedData);
                },
                2000);

        });
    },
    
    helperHandleRowSelect : function(component,event,helper){
        debugger;
        var selectedBusinessPark = '';
        var selectedBuilding = '';
        var selectedRows = component.find('treegrid_async').getSelectedRows();
        debugger;
        for(var index in selectedRows){
            if(selectedRows[index].level == 1){
                selectedBusinessPark = selectedBusinessPark + selectedRows[index].code + ';'
            }
            if(selectedRows[index].level == 2){
                selectedBuilding = selectedBuilding + selectedRows[index].code + ';'
            }
        }
        selectedBusinessPark = selectedBusinessPark.substring(0,selectedBusinessPark.length - 1);
        selectedBuilding = selectedBuilding.substring(0,selectedBuilding.length - 1);
        debugger;
        component.set("v.selectedBusinessPark",selectedBusinessPark);
        component.set("v.selectedBuilding",selectedBuilding);
    }
}) // eslint-disable-line