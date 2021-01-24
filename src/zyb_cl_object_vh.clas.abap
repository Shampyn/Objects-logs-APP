CLASS zyb_cl_object_vh DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zyb_cl_object_vh IMPLEMENTATION.
 METHOD if_rap_query_provider~select.
    DATA: lo_request  TYPE REF TO /iwbep/if_cp_request_read_list,
          lo_response TYPE REF TO /iwbep/if_cp_response_read_lst.
    TYPES:
      tv_description TYPE  if_xco_aplo_content=>tv_description,
      tv_object      TYPE sxco_aplo_object_name,

      BEGIN OF ts_content,
        object      TYPE tv_object,
        object_text TYPE tv_description,
      END OF ts_content.

    DATA ls_vh_object TYPE zce_object_vh.
    DATA lt_vh_object TYPE TABLE OF zce_object_vh.
    DATA ls_object_text TYPE ts_content.
    DATA lt_object_text TYPE TABLE OF ts_content.

    IF io_request->is_data_requested( ).

      DATA(lt_objects) = xco_cp_abap_repository=>objects->aplo->all->in( xco_cp_abap=>repository )->get(  ).
      LOOP AT lt_objects INTO DATA(ls_objects).
        DATA(lv_object) = ls_objects->name.
        DATA(lv_object_text) = ls_objects->content(  )->get_description(  ).
        ls_object_text-object = lv_object.
        ls_object_text-object_text = lv_object_text.
        APPEND ls_object_text  TO lt_object_text.

      ENDLOOP.

      SELECT DISTINCT *
      FROM zi_vh_object
      where ABAPObjectIsDeleted <> 'X'
      INTO TABLE @DATA(lt_vh).

      LOOP AT lt_vh INTO DATA(ls_vh).
        DATA(lv_text) = lt_object_text[ object = ls_vh-ABAPObject ]-object_text.
        ls_vh_object-object_text = lv_text.
        ls_vh_object-object = ls_vh-ABAPObject.
        ls_vh_object-package_obj = ls_vh-ABAPPackage.
        APPEND ls_vh_object TO lt_vh_object.
      ENDLOOP.

    ENDIF.
    TRY.

        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
        DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
        DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
        DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                                    ELSE lv_page_size ).

        DATA(sort_elements) = io_request->get_sort_elements( ).
        DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
                                                   ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true
                                                                                          THEN ` descending`
                                                                                          ELSE ` ascending` ) ) ).
        DATA(lv_sort_string)  = COND #( WHEN lt_sort_criteria IS INITIAL
                                        THEN 'object'
                                        ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).

        DATA(lt_req_elements) = io_request->get_requested_elements( ).
        DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = `, ` ).

        IF io_request->is_data_requested( ).
          DATA lt_travel_response TYPE STANDARD TABLE OF zce_object_vh.

          SELECT (lv_req_elements) FROM @lt_vh_object AS object
                   WHERE (lv_sql_filter)
                   ORDER BY (lv_sort_string)
                   INTO CORRESPONDING FIELDS OF TABLE @lt_travel_response
                   OFFSET @lv_offset UP TO @lv_max_rows ROWS.

          io_response->set_data( lt_travel_response ).
        ENDIF.

        IF io_request->is_total_numb_of_rec_requested( ).

          SELECT COUNT( * ) FROM @lt_travel_response AS response
                            INTO @DATA(lv_object_count).

          io_response->set_total_number_of_records( lv_object_count ).
        ENDIF.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        RAISE EXCEPTION TYPE zcx_soap_exeption
          EXPORTING
            textid   = zcx_soap_exeption=>query_failed
            previous = lx_gateway.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
