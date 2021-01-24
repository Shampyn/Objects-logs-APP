CLASS lhc_object DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS: BEGIN OF ls_c_status,
                 lv_active   TYPE c LENGTH 1 VALUE 'A',
                 lv_inactive TYPE c LENGTH 1 VALUE 'I',
               END OF ls_c_status.
    CONSTANTS i TYPE string VALUE 'I' ##NO_TEXT.
    "constant structure
    METHODS create_subobject FOR DETERMINE ON SAVE
      IMPORTING keys FOR object~createsubobject.
    METHODS set_status_active FOR MODIFY
      IMPORTING keys FOR ACTION object~setstatusactive RESULT result.
    METHODS set_status_inactive FOR MODIFY
      IMPORTING keys FOR ACTION object~setstatusinactive RESULT result.
    METHODS fill_status FOR DETERMINE ON SAVE
      IMPORTING keys FOR object~fillstatus.
    METHODS change_status FOR MODIFY
      IMPORTING keys FOR ACTION object~changestatus RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR object RESULT result.

ENDCLASS.

CLASS lhc_object IMPLEMENTATION.

  METHOD create_subobject.
    DATA lt_modify TYPE TABLE FOR CREATE zyb_i_object_cds1\_subobject.
    DATA ls_modify LIKE LINE OF lt_modify.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
                  ENTITY object
                  FIELDS ( object )
                  WITH CORRESPONDING #( keys )
                RESULT DATA(lt_object)
               REPORTED DATA(lt_reported).

    DATA(lo_log_object) = cl_bali_object_handler=>get_instance( ).
    LOOP AT lt_object ASSIGNING FIELD-SYMBOL(<lfs_object>).
      TRY.

          lo_log_object->read_object(
            EXPORTING
              iv_object      = <lfs_object>-object
            IMPORTING
              et_subobjects  = DATA(lt_subobjects)
          ).
        CATCH cx_bali_objects INTO DATA(lx_exception).

      ENDTRY.

      IF lt_subobjects IS NOT INITIAL.
        ls_modify = VALUE #( %key = <lfs_object>-%key
                             %target = VALUE #( FOR ls_subobjects IN lt_subobjects
                                                  ( %data-subobject = ls_subobjects-subobject
                                                    %data-subobjecttext = ls_subobjects-subobject_text
                                                    %data-status = ls_c_status-lv_active
                                                  )
                                              )
                             ).

        APPEND ls_modify TO lt_modify.
      ENDIF.
    ENDLOOP.

    IF lt_modify IS NOT INITIAL.

      MODIFY ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
        ENTITY object
          CREATE BY \_subobject
          FIELDS ( subobject
                   subobjecttext
                   status )
          WITH lt_modify
      REPORTED DATA(lt_reported_sub).

      reported-subobject = CORRESPONDING #( BASE ( reported-subobject ) lt_reported_sub-subobject
                                            MAPPING object = object
                                                    subobject = subobject  ).
      reported-object = CORRESPONDING #( BASE ( reported-object ) lt_reported-object
                                         MAPPING object = object ).
    ENDIF.

  ENDMETHOD.

  METHOD set_status_active.

    MODIFY ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
                 ENTITY object
                    EXECUTE changestatus

                    FROM CORRESPONDING #( keys )
                    RESULT DATA(lt_status_object)
                 FAILED   failed
                 REPORTED reported.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
          ENTITY object
            ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_object).

    DATA(lo_log_object) = cl_bali_object_handler=>get_instance( ).

    LOOP AT lt_object ASSIGNING FIELD-SYMBOL(<lfs_object>).
      TRY.
          lo_log_object->create_object( EXPORTING iv_object = <lfs_object>-%data-object
                                                  iv_object_text = <lfs_object>-%data-objecttext
                                                  iv_package = <lfs_object>-%data-packagename
                                                  iv_transport_request = <lfs_object>-%data-transportrequest ).
        CATCH cx_bali_objects INTO DATA(lx_exception).
          APPEND VALUE #( %tky = <lfs_object>-%tky ) TO failed-object.
          APPEND VALUE #( %tky = <lfs_object>-%tky
                          %msg  = new_message( id        = 'ZYB_CM_TEXT'
                                               number    = '004'
                                               v1        = <lfs_object>-object
                                               severity = if_abap_behv_message=>severity-error )
                                              )
            TO reported-object.
      ENDTRY.

    ENDLOOP.

    result = VALUE #( FOR object IN lt_object ( object = object-object
                                                %param    = object ) ).
  ENDMETHOD.

  METHOD set_status_inactive.
    DATA lt_modify TYPE TABLE FOR UPDATE  zyb_i_subobject_cds1.
    DATA ls_modify LIKE LINE OF lt_modify.

    MODIFY ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
             ENTITY object
                EXECUTE changestatus
                FROM CORRESPONDING #( keys )
                RESULT DATA(lt_status_object)
             FAILED   failed
             REPORTED reported.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
          ENTITY object
            ALL FIELDS
            WITH CORRESPONDING #( keys )
          RESULT DATA(lt_object)
          FAILED   failed
          REPORTED reported.

    DATA(lo_log_object) = cl_bali_object_handler=>get_instance( ).
    LOOP AT lt_object ASSIGNING FIELD-SYMBOL(<lfs_object>).
      TRY.
          lo_log_object->read_object(
            EXPORTING
              iv_object = <lfs_object>-object
            IMPORTING
              et_subobjects = DATA(lt_subobjects)
           ).

          IF lt_subobjects IS NOT INITIAL.

            LOOP AT lt_subobjects ASSIGNING FIELD-SYMBOL(<lfs_subobject>).
              ls_modify = VALUE #( %tky-object = <lfs_object>-object
                                   %tky-subobject = <lfs_subobject>-subobject
                                   status = ls_c_status-lv_inactive
                                   transportrequest = <lfs_object>-%data-transportrequest
              ).
              APPEND ls_modify TO lt_modify.

            ENDLOOP.
          ENDIF.

          lo_log_object->delete_object(
             EXPORTING
                 iv_object = <lfs_object>-%data-object
                 iv_transport_request = <lfs_object>-%data-transportrequest
          ).
        CATCH cx_bali_objects INTO DATA(lx_exception).

          APPEND VALUE #( %tky = <lfs_object>-%tky ) TO failed-object.
          APPEND VALUE #( %tky = <lfs_object>-%tky
                          %msg  = new_message( id        = 'ZYB_CM_TEXT'
                                               number    = '005'
                                               v1        = <lfs_object>-object
                                               severity = if_abap_behv_message=>severity-error )
                                              )
            TO reported-object.
      ENDTRY.

    ENDLOOP.

    IF lt_modify IS NOT INITIAL.

      MODIFY ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
                ENTITY subobject
                  UPDATE FIELDS ( status transportrequest )
                  WITH lt_modify
              FAILED   failed
              REPORTED reported.
    ENDIF.

    result = VALUE #( FOR object IN lt_object ( object = object-object
                                                %param    = object ) ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
       ENTITY object
          FIELDS ( status )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_object_result)
        REPORTED reported
        FAILED failed.

    result = VALUE #( FOR ls_object IN lt_object_result
                       ( %key                           = ls_object-%key
                         %features-%action-setstatusactive = COND #( WHEN ls_object-status = ls_c_status-lv_active
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled  )
                         %features-%action-setstatusinactive = COND #( WHEN ls_object-status = ls_c_status-lv_inactive
                                                                       THEN if_abap_behv=>fc-o-disabled
                                                                       ELSE if_abap_behv=>fc-o-enabled   )
                         %features-%update               = COND #(  WHEN ls_object-status = ls_c_status-lv_active
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled  )
                         %features-%delete               = COND #(  WHEN ls_object-status = ls_c_status-lv_active
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled  )
                      ) ).

  ENDMETHOD.

  METHOD fill_status.
    DATA lt_modify TYPE TABLE FOR UPDATE  zyb_i_object_cds1.
    DATA ls_modify LIKE LINE OF lt_modify.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
      ENTITY object
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_object)
      REPORTED DATA(lt_reported).

    IF lt_object IS NOT INITIAL.
      DATA(lo_log_object) = cl_bali_object_handler=>get_instance( ).

      LOOP AT lt_object ASSIGNING FIELD-SYMBOL(<lfs_object>).
        TRY.
            lo_log_object->read_object(
             EXPORTING
                iv_object = <lfs_object>-object
             IMPORTING
                ev_object_text = DATA(lv_object_text)
             ).

            ls_modify = VALUE #( %tky = <lfs_object>-%tky
                                 status = ls_c_status-lv_active
                               ).
            APPEND ls_modify TO lt_modify.

          CATCH cx_bali_objects INTO DATA(lx_exception).
            ls_modify = VALUE #( %tky = <lfs_object>-%tky
                                 status = ls_c_status-lv_inactive
                               ).
            APPEND ls_modify TO lt_modify.
        ENDTRY.
      ENDLOOP.



      IF lt_modify  IS NOT INITIAL.

        MODIFY ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
          ENTITY object
            UPDATE FIELDS ( status )
            WITH lt_modify
        REPORTED lt_reported.

      ENDIF.
    ENDIF.

    reported-object = CORRESPONDING #( BASE ( reported-object ) lt_reported-object MAPPING object = object ).
  ENDMETHOD.

  METHOD change_status.
    DATA lt_modify TYPE TABLE FOR UPDATE  zyb_i_object_cds1.
    DATA ls_modify LIKE LINE OF lt_modify.

    READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
     ENTITY object
         FIELDS ( status  )
         WITH CORRESPONDING #( keys )
     RESULT DATA(lt_object)
     REPORTED reported
     FAILED failed.

    IF lt_object IS NOT INITIAL.
      " try catch for access to table cx_sy_itab_line_not_found
      LOOP AT lt_object ASSIGNING FIELD-SYMBOL(<lfs_object>).
      TRY.
        ls_modify = VALUE #( %tky = <lfs_object>-%tky
                             transportrequest = keys[ KEY entity COMPONENTS object = <lfs_object>-object ]-%param-transport_request
                             status = COND #(  WHEN <lfs_object>-status = ls_c_status-lv_active
                                               THEN ls_c_status-lv_inactive
                                               ELSE ls_c_status-lv_active
                                            )
                           ).
        APPEND ls_modify TO lt_modify.
      CATCH cx_sy_itab_line_not_found INTO DATA(lx_exception).
      ENDTRY.
      ENDLOOP.

      IF lt_modify IS NOT INITIAL.

        MODIFY ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
            ENTITY object
              UPDATE FIELDS ( status
                              transportrequest )
              WITH lt_modify
          REPORTED reported
          FAILED failed.
      ENDIF.

      READ ENTITIES OF zyb_i_object_cds1 IN LOCAL MODE
        ENTITY object
          FIELDS ( status )
          WITH CORRESPONDING #( keys )
      RESULT lt_object
      REPORTED reported
      FAILED failed.

      result = VALUE #( FOR object IN lt_object ( object = object-object
                                                  %param    = object ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
