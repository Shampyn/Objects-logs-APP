@EndUserText.label: 'projection for object'
@AccessControl.authorizationCheck: #NOT_REQUIRED


@UI: {
  headerInfo: { typeName: 'Application Log Object', typeNamePlural: 'Application Log Objects',
                title: { type: #STANDARD, value: 'Object'} } }

@Search.searchable: true
define root view entity ZYB_C_OBJECT_CDS1
  as projection on ZYB_I_OBJECT_CDS1
{
       @UI.facet: [{ id:            'Object',
                       purpose:       #STANDARD,
                       type:          #IDENTIFICATION_REFERENCE,
                       label:         'Object',
                       position:      10
                     },
                     { id:            'Admin_data',
                       purpose:       #STANDARD,
                       type:          #IDENTIFICATION_REFERENCE,
                       label:         'Admin data',
                       targetQualifier: 'Admin',
                       position:      30
                     },
                     { id:            'Subobject',
                       purpose:       #STANDARD,
                       type:          #LINEITEM_REFERENCE,
                       label:         'Subobject',
                       position:      20,
                       targetElement: '_subobject'}]

       @UI: { lineItem:       [ { position: 20, importance: #HIGH, label:'Object' }] ,
              identification: [ { position: 20, label:'Object' } ],
              selectionField: [{position: 10 }] }

       @Consumption.valueHelpDefinition: [{ entity : {name: 'ZYB_OBJECT_VH', element: 'Object'  },
       additionalBinding: [{ localElement: 'PackageName', element: 'package_obj', usage: #RESULT },
       { localElement: 'ObjectText', element: 'object_text', usage: #RESULT },
       { localElement: 'Object', element: 'object', usage: #RESULT }]}]
       @Search: { defaultSearchElement: true,fuzzinessThreshold: 0.7 }
  key  Object,
       @UI: { lineItem:       [ { position: 30, importance: #HIGH, label:'Object text' } ] ,
          identification: [ { position: 30, label:'Object text' } ] }
       @Search: { defaultSearchElement: true,fuzzinessThreshold: 0.7 }
       ObjectText,
       @UI: { lineItem:       [ { position: 60, importance: #HIGH, label:'Transport request' } ] ,
          identification: [ { position: 60, label:'Transport request' } ] }
       TransportRequest,
       @UI: { lineItem:       [ { position: 50, importance: #HIGH, label:'Package name' } ] ,
          identification: [ { position: 50, label:'Package name' } ],
          selectionField: [{position: 20 }]
           }
       @EndUserText.label: 'Package name'
       @Search: { defaultSearchElement: true,fuzzinessThreshold: 0.7 }
       @Consumption.valueHelpDefinition: [{ entity : {name: 'ZYB_PACKAGE_VH', element: 'ABAPPackage'  } }]
       PackageName,
       @UI: {
         lineItem:       [ { position: 40, importance: #HIGH, label:'Status',criticality: 'criticality',criticalityRepresentation: #WITHOUT_ICON },
                           { type: #FOR_ACTION, dataAction: 'setStatusActive', label: 'Activate', position: 70 },
                           { type: #FOR_ACTION, dataAction: 'setStatusInactive', label: 'Deactivate', position: 80 }],
         identification: [ { position: 40, label:'Status',criticality: 'criticality',criticalityRepresentation: #WITHOUT_ICON },
                           { type: #FOR_ACTION, dataAction: 'setStatusActive', label: 'Activate', position: 70 },
                           { type: #FOR_ACTION, dataAction: 'setStatusInactive', label: 'Deactivate', position: 80 }]}
       Status,
       @UI.hidden: true
       criticality,
       @UI.hidden: true
       status_description,
       @UI: { identification: [ { position: 10, label:'Created by',qualifier: 'Admin' } ] }
       @Consumption.filter.hidden: true
       LocalCreatedBy,
       @UI: { identification: [ { position: 20, label:'Created at',qualifier: 'Admin' } ] }
       @Consumption.filter.hidden: true
       LocalCreatedAt,
       @UI: { identification: [ { position: 30, label:'Last changed by',qualifier: 'Admin' } ] }
       @Consumption.filter.hidden: true
       LocalLastChangedBy,
       @UI: { identification: [ { position: 40, label:'Last changed at',qualifier: 'Admin' } ] }
       @Consumption.filter.hidden: true
       LocalLastChangedAt,
       /* Associations */
       _subobject : redirected to composition child ZYB_C_SUBOBJECT_CDS1
}
