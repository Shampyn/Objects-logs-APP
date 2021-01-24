@EndUserText.label: 'projection for subobject'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI: {
  headerInfo: { typeName: 'Application Log Subobject', typeNamePlural: 'Application Log Objects',
                title: { type: #STANDARD, value: 'Subobject' } } }

define view entity ZYB_C_SUBOBJECT_CDS1
  as projection on ZYB_I_SUBOBJECT_CDS1
{
       @UI.facet: [ { id:            'Subobject',
                        purpose:       #STANDARD,
                        type:          #IDENTIFICATION_REFERENCE,
                        label:         'Subobject',
                        position:      10 },
                     { id:            'Admin_data',
                        purpose:       #STANDARD,
                        type:          #IDENTIFICATION_REFERENCE,
                        label:         'Admin data',
                        targetQualifier: 'Admin',
                        position:      20}
                     ]



       @UI.hidden: true
  key  Object,
       @UI: { lineItem:       [ { position: 20, importance: #HIGH, label:'Subobject' } ],
          identification: [ { position: 20, label:'Subobject' } ] }
  key  Subobject,

       @UI: { lineItem:       [ { position: 30, importance: #HIGH, label:'Subobject text' } ],
         identification: [ { position: 30, label:'Subobject text' } ] }
       SubobjectText,
       @UI: { lineItem:       [ { position: 60, importance: #HIGH, label:'Transport request' } ],
         identification: [ { position: 60, label:'Transport request' } ] }
       TransportRequest,
       @UI: { lineItem:       [ { position: 50, importance: #HIGH, label:'Package name' } ] }
       _object.PackageName,
       @UI: {
         lineItem:       [ { position: 40, importance: #HIGH, label:'Status', criticality: 'criticality', criticalityRepresentation: #WITHOUT_ICON },
                           { type: #FOR_ACTION, dataAction: 'setStatusSubActive', label: 'Activate' },
                           { type: #FOR_ACTION, dataAction: 'setStatusSubInactive', label: 'Deactivate' }
                           ],
         identification: [ { position: 40, label:'Status',criticality: 'criticality', criticalityRepresentation: #WITHOUT_ICON },
                           { type: #FOR_ACTION, dataAction: 'setStatusSubActive', label: 'Activate', position: 70 },
                           { type: #FOR_ACTION, dataAction: 'setStatusSubInactive', label: 'Deactivate', position: 80 }] }
       Status,
       @UI.hidden: true
       status_description,
       @UI.hidden: true
       criticality,
       @UI: { identification: [ { position: 10, label:'Created by',qualifier: 'Admin' } ] }
       @Consumption.filter.hidden: true
       LocalCreatedBy,
       @UI: { identification: [ { position: 20, label:'Created at',qualifier: 'Admin' } ] }
       @Consumption.filter.hidden: true
       LocalCreatedAt,
       @UI: {  identification: [ { position: 30, label:'Last changed by',qualifier: 'Admin' } ] }
       @Consumption.filter.hidden: true
       LocalLastChangedBy,
       @UI: { identification: [ { position: 40, label:'Last changed at',qualifier: 'Admin' } ] }
       @Consumption.filter.hidden: true
       LocalLastChangedAt,
       /* Associations */
       _object : redirected to parent ZYB_C_OBJECT_CDS1
}
