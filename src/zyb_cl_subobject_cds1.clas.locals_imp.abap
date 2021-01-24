CLASS lhc_subobject DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS: BEGIN OF ls_c_status,
                 lv_active   TYPE c LENGTH 1 VALUE 'A',
                 lv_inactive TYPE c LENGTH 1 VALUE 'I',
               END OF ls_c_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR subobject RESULT result.

    METHODS set_status_active FOR MODIFY
      IMPORTING keys FOR ACTION subobject~setstatussubactive RESULT result.

    METHODS set_status_inactive FOR MODIFY
      IMPORTING keys FOR ACTION subobject~setstatussubinactive RESULT result.
    METHODS change_status_subobject FOR MODIFY
      IMPORTING keys FOR ACTION subobject~changestatussubobject RESULT result.
    METHODS fill_status_sub FOR DETERMINE ON SAVE
      IMPORTING keys FOR subobject~fillstatussub.

ENDCLASS.

CLASS lhc_subobject IMPLEMENTATION.

  METHOD get_instance_features.
    DATA ls_result LIKE LINE OF result.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
         ENTITY subobject
            FIELDS ( status )
            WITH CORRESPONDING #( keys )
          RESULT DATA(lt_subobject_result)
          REPORTED reported
          FAILED failed.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
         ENTITY object
            FIELDS ( status
                     object )
            WITH CORRESPONDING #( keys )
          RESULT DATA(lt_object_result)
          REPORTED reported
          FAILED failed.
" change on loop


    LOOP AT lt_subobject_result ASSIGNING FIELD-SYMBOL(<lsf_subobject>).

    TRY.
    ls_result-%key = <lsf_subobject>-%key.
    ls_result-%action-setstatussubinactive = COND #( WHEN <lsf_subobject>-status = ls_c_status-lv_active
                                                     THEN if_abap_behv=>fc-o-enabled
                                                     ELSE  if_abap_behv=>fc-o-disabled ).
    ls_result-%features-%update               = COND #( WHEN <lsf_subobject>-status = ls_c_status-lv_active
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled  ).
    ls_result-%features-%delete               = COND #( WHEN <lsf_subobject>-status = ls_c_status-lv_active
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled  ).
    ls_result-%action-setstatussubactive = COND #( WHEN <lsf_subobject>-status = ls_c_status-lv_inactive
                                                   AND lt_object_result[ KEY entity COMPONENTS object = <lsf_subobject>-object ]-status = ls_c_status-lv_active
                                                   THEN if_abap_behv=>fc-o-enabled
                                                   ELSE if_abap_behv=>fc-o-disabled ).
    APPEND ls_result TO result.

    CATCH cx_sy_itab_line_not_found INTO DATA(lx_exception).
    ls_result-%action-setstatussubactive = abap_false.
    APPEND ls_result TO result.

    ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD set_status_active.
    MODIFY ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
                ENTITY   subobject
                   EXECUTE changestatussubobject
                   FROM CORRESPONDING #( keys )
                   RESULT DATA(lt_status_subobject)
                FAILED   failed
                REPORTED reported.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
          ENTITY subobject
            ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_subobject)
          FAILED   failed
          REPORTED reported.

    IF lt_subobject IS NOT INITIAL.

      DATA(lo_log_object) = cl_bali_object_handler=>get_instance( ).
      LOOP AT lt_subobject ASSIGNING FIELD-SYMBOL(<lfs_subobject>).
        TRY.
            lo_log_object->add_subobject(
              EXPORTING
                iv_object = <lfs_subobject>-%data-object
                iv_subobject = <lfs_subobject>-%data-subobject
                iv_subobject_text = <lfs_subobject>-%data-subobjecttext
                iv_transport_request = <lfs_subobject>-%data-transportrequest
            ).

          CATCH cx_bali_objects INTO DATA(lx_exception).
            APPEND VALUE #( %tky = <lfs_subobject>-%tky ) TO failed-subobject.
            APPEND VALUE #( %tky = <lfs_subobject>-%tky
                            %msg  = new_message( id        = 'ZYB_CM_TEXT'
                                                 number    = '007'
                                                 v1        = <lfs_subobject>-subobject
                                                 severity = if_abap_behv_message=>severity-error )
                                                )
              TO reported-subobject.
        ENDTRY.
      ENDLOOP.
    ENDIF.

    result = VALUE #( FOR subobject IN lt_subobject ( subobject = subobject-subobject
                                                      object    = subobject-object
                                                      %param    = subobject ) ).
  ENDMETHOD.

  METHOD set_status_inactive.
    MODIFY ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
               ENTITY subobject
                  EXECUTE changestatussubobject
                  FROM CORRESPONDING #( keys )
                  RESULT DATA(lt_status_subobject)
               FAILED   failed
               REPORTED reported.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
          ENTITY subobject
            ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_subobject)
          FAILED   failed
          REPORTED reported.

    IF lt_subobject IS NOT INITIAL.

      DATA(lo_log_object) = cl_bali_object_handler=>get_instance( ).
      LOOP AT lt_subobject ASSIGNING FIELD-SYMBOL(<lfs_subobject>).
        TRY.
            lo_log_object->delete_subobject(
              EXPORTING
                iv_object = <lfs_subobject>-%data-object
                iv_subobject = <lfs_subobject>-%data-subobject
                iv_transport_request = <lfs_subobject>-%data-transportrequest
             ).

          CATCH cx_bali_objects INTO DATA(lx_exception).
            APPEND VALUE #( %tky = <lfs_subobject>-%tky ) TO failed-subobject.
            APPEND VALUE #( %tky = <lfs_subobject>-%tky
                            %msg  = new_message( id        = 'ZYB_CM_TEXT'
                                                 number    = '008'
                                                 v1        = <lfs_subobject>-subobject
                                                 severity = if_abap_behv_message=>severity-error )
                                                )
              TO reported-subobject.
        ENDTRY.
      ENDLOOP.
    ENDIF.

    result = VALUE #( FOR subobject IN lt_subobject ( subobject = subobject-subobject
                                                      object    = subobject-object
                                                      %param    = subobject ) ).
  ENDMETHOD.

  METHOD change_status_subobject.
    DATA lt_modify TYPE TABLE FOR UPDATE  zyb_i_subobject_cds1.
    DATA ls_modify LIKE LINE OF lt_modify.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
     ENTITY subobject
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
     RESULT DATA(lt_subobject)
     REPORTED reported
     FAILED failed.

    IF lt_subobject IS NOT INITIAL.

      LOOP AT lt_subobject ASSIGNING FIELD-SYMBOL(<lfs_subobject>).
        TRY.
            ls_modify = VALUE #( %tky = <lfs_subobject>-%tky
                                 status = COND #(  WHEN <lfs_subobject>-status = ls_c_status-lv_active
                                                   THEN ls_c_status-lv_inactive
                                                   ELSE ls_c_status-lv_active
                                                )
                                 transportrequest = keys[ KEY entity COMPONENTS object = <lfs_subobject>-object
                                                                                subobject = <lfs_subobject>-subobject ]-%param-transport_request
                               ).
            APPEND ls_modify TO lt_modify.
          CATCH cx_sy_itab_line_not_found INTO DATA(lx_exception).
        ENDTRY.
      ENDLOOP.

      MODIFY ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
          ENTITY subobject
            UPDATE FIELDS ( status
                            transportrequest )
            WITH lt_modify
        REPORTED reported
        FAILED failed.

      result = VALUE #( FOR object IN lt_subobject ( object = object-object
                                                     %param    = object ) ).
    ENDIF.
  ENDMETHOD.

  METHOD fill_status_sub.
    DATA lt_modify TYPE TABLE FOR UPDATE zyb_i_subobject_cds1.
    DATA ls_modify LIKE LINE OF lt_modify.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
                  ENTITY subobject
                    FIELDS ( status )
                  WITH CORRESPONDING #( keys )
                RESULT DATA(lt_subobject).

    LOOP AT lt_subobject ASSIGNING FIELD-SYMBOL(<lfs_subobject>).

      IF <lfs_subobject>-status <> ls_c_status-lv_active.
        ls_modify = VALUE #( %tky = <lfs_subobject>-%tky
                             status = ls_c_status-lv_inactive ).
        APPEND ls_modify TO lt_modify.
      ENDIF.
    ENDLOOP.

    IF lt_modify IS NOT INITIAL.

      MODIFY ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
            ENTITY subobject
              UPDATE FIELDS ( status )
              WITH lt_modify
          REPORTED DATA(lt_reported).

      reported-subobject = CORRESPONDING #( BASE ( reported-subobject ) lt_reported-subobject
                                            MAPPING object = object
                                                    subobject = subobject  ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
