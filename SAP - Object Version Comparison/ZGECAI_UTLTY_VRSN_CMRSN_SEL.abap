*&---------------------------------------------------------------------*
*&  Include           ZGECAI_UTLTY_VRSN_CMRSN_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-t01.
SELECT-OPTIONS s_pkg FOR tadir-devclass.
PARAMETERS p_dest TYPE rfcdest.
PARAMETERS p_clas AS CHECKBOX.
SELECTION-SCREEN COMMENT /1(30) com2 FOR FIELD p_clas.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE text-t02.
PARAMETERS p_var TYPE disvariant-variant.
SELECTION-SCREEN END OF BLOCK blk2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dest.
  PERFORM f_help_on_value_request TABLES gt_logsys USING 'P_DEST' 'LOGSYS' 'RFC Destination for Version Comparison'(021).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_var.
  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      is_variant    = gwa_variant
      i_save        = 'A'
    IMPORTING
      e_exit        = gv_exit
      es_variant    = gwa_variantx
    EXCEPTIONS
      not_found     = 1
      program_error = 2.
  IF sy-subrc <> 0.
    CLEAR p_var.
  ELSE.
    IF gv_exit = space.
      p_var = gwa_variantx-variant.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.

  IF p_var IS NOT INITIAL.
    gwa_variant-variant = p_var.
    CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = gwa_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CLEAR gwa_variant.
  ENDIF.

*————————————————————————————————————————*
* CLASS LCL_EVENT_RECEIVER DEFINITION
*———————————————————————————————————————-*
CLASS lcl_event_receiver DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:

    handle_top_of_page FOR EVENT top_of_page
                         OF cl_gui_alv_grid
                         IMPORTING e_dyndoc_id.


ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION
*———————————————————————————————————————-*
* CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*———————————————————————————————————————-*
CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_top_of_page.                   "implementation

    PERFORM f_event_top_of_page USING go_dyndoc_id.
  ENDMETHOD.                            "top_of_page

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

DATA: g_handler TYPE REF TO lcl_event_receiver.
