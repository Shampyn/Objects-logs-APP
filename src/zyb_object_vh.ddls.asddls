@EndUserText.label: 'object value help'
@ObjectModel.query.implementedBy: 'ABAP:ZYB_CL_OBJECT_VH'
define custom entity ZYB_OBJECT_VH
{
  key object      : zyb_object;
      object_text : zyb_object_text;
      package_obj : zyb_package_name;

}
