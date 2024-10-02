CLASS /yga/cl_transp_control DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .





      "! <p class="shorttext synchronized" lang="pt">Salvar log de "Alteração de Status"</p>
      METHODS set_log_status
      IMPORTING im_change_request    TYPE /yga/charm_change
                im_transport_request TYPE tr_trkorr
                im_status            TYPE /yga/status_aprov.

ENDCLASS.



METHOD progress .

    DATA:
      percentage TYPE i .

    " Não sera exibido quando for em background
    IF ( sy-batch EQ abap_true ) .
      RETURN .
    ENDIF .

    IF ( percent IS INITIAL ) AND
       ( ( total IS INITIAL ) AND currency IS INITIAL ) .
      RETURN .
    ENDIF .

    IF ( percent IS NOT INITIAL ) .
      percentage = percent .
    ELSE .
      TRY .
          percentage = ( currency * 100 ) / total.
        CATCH cx_sy_zerodivide .
          percentage = 10 .
      ENDTRY .
    ENDIF .

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = percentage  " Size of Bar ( 0 <= PERCENTAGE <= 100 )
        text       = message.    " Text to be Displayed

  ENDMETHOD .

  METHOD set_log_status .

    CONSTANTS:
      BEGIN OF lc_log,
        object    TYPE balobj_d  VALUE '/YGA/JUMP',
        subobject TYPE balsubobj VALUE 'TRANSP_CTRL',
      END OF lc_log,
      BEGIN OF lc_status,
        aprovado  TYPE /yga/transp_ctrl-status_aprov VALUE '✓',
        nao_aprov TYPE /yga/transp_ctrl-status_aprov VALUE '✗',
      END OF lc_status,
      lc_expirate TYPE i VALUE 90.

    IF    im_change_request IS INITIAL
       OR im_status         IS INITIAL.
      RETURN.
    ENDIF.

    DATA(message_list) = cf_reca_message_list=>create( id_object    = lc_log-object
                                                       id_subobject = lc_log-subobject
                                                       id_extnumber = CONV balnrext( im_change_request )
                                                       id_deldate   = |{ sy-datum + lc_expirate }| ).
    IF message_list IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lv_status) = COND char50( WHEN im_status = me->gc_status_ot-aprovado
                                   THEN |{ lc_status-aprovado } Aprovado|
                                   ELSE |{ lc_status-nao_aprov } Não aprovado| ).

    message_list->add( id_msgty = if_xo_const_message=>info
                       id_msgid = '>0'
                       id_msgno = '000'
                       id_msgv1 = |O Status do CD { im_change_request }|
                       id_msgv2 = |foi alterado p/ { lv_status }|
                       id_msgv3 = |({ sy-uname } { sy-datum DATE = USER } { sy-uzeit TIME = USER }).| ).

    message_list->add( id_msgty = if_xo_const_message=>info
                       id_msgid = '>0'
                       id_msgno = '000'
                       id_msgv1 = |O Status da TR { im_transport_request }|
                       id_msgv2 = |foi alterado p/ { lv_status }|
                       id_msgv3 = |({ sy-uname } { sy-datum DATE = USER } { sy-uzeit TIME = USER }).| ).

    message_list->store( ).

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD .

ENDCLASS.