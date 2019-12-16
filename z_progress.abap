report z_progress .

parameters: p_times1 type i default  15, "Immediately
            p_times2 type i default  42. "Once per 10 seconds


do p_times1 times.

cl_progress_indicator=>progress_indicate(
  exporting
     i_text               = | Output immediately { sy-index } / { p_times1 } |
*    i_msgid              = i_msgid    " Message Class (If I_TEXT is not transferred)
*    i_msgno              = i_msgno    " Message Number (If I_TEXT is not transferred)
*    i_msgv1              = i_msgv1    " Message Variable (Maximum of 50 Characters)
*    i_msgv2              = i_msgv2    " Message Variable (Maximum of 50 Characters)
*    i_msgv3              = i_msgv3    " Message Variable (Maximum of 50 Characters)
*    i_msgv4              = i_msgv4    " Message Variable (Maximum of 50 Characters)
    i_processed          = sy-index    " Number of Objects Already Processed
    i_total              = p_times1    " Total Number of Objects to Be Processed
    i_output_immediately = abap_true    " X = Display Progress Immediately
*  importing
*    e_progress_sent      = e_progress_sent    " X = Progress Information Was Displayed
).
    wait up to 1 seconds.

enddo.
