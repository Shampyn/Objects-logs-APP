@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'object basic'
define root view entity ZYB_I_OBJECT_CDS1
  as select from zyb_object_d1
  composition [0..*] of ZYB_I_SUBOBJECT_CDS1 as _subobject
{
  key object                as Object,
      object_text           as ObjectText,
      transport_request     as TransportRequest,
      package_name          as PackageName,
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
      _subobject
}
