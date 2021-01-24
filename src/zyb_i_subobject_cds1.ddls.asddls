@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'subobject basic'
define view entity ZYB_I_SUBOBJECT_CDS1
  as select from zyb_subobject_d1
  association to parent ZYB_I_OBJECT_CDS1 as _object on $projection.Object = _object.Object
{
  key    object                as Object,
  key    subobject             as Subobject,

         subobject_text        as SubobjectText,
         transport_request     as TransportRequest,
         @ObjectModel.text.element: ['status_description']
         status                as Status,
         case status
         when 'A' then 'Active'
         when 'I' then 'Inactive'
         else 'Not defined'
         end                   as status_description,
         case status
         when 'A' then 3
         when 'I' then 1
         else 0
         end                   as criticality,
         @Semantics.user.createdBy: true
         local_created_by      as LocalCreatedBy,
         @Semantics.systemDateTime.createdAt: true
         local_created_at      as LocalCreatedAt,
         @Semantics.user.lastChangedBy: true
         local_last_changed_by as LocalLastChangedBy,
         //local ETag field --> OData ETag
         @Semantics.systemDateTime.localInstanceLastChangedAt: true
         local_last_changed_at as LocalLastChangedAt,
         _object
}
