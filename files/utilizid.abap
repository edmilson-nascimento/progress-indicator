

me->progress(
    EXPORTING
      percent  = 90
      message  = 'Visualização de dados'(m02)
  ).


  
  DATA(lv_message) = CONV char50( |{ 'Processar'(m06) } { sy-tabix }| ) .
  lv_message = |{ lv_message } { 'de'(m07) } { lines( me->gt_transp_ctrl ) }{ '...'(m08) }| .

  me->progress(
    EXPORTING
      total    = lines( gt_transp_ctrl )
      currency = sy-tabix
      message  = lv_message
  ).
