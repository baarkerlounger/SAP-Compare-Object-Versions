TYPE-POOLS ole2 .

DATA: gv_workbook      TYPE                   ole2_object,
      gv_sheet         TYPE                   ole2_object,
      gv_cell          TYPE                   ole2_object,
      gv_cell2         TYPE                   ole2_object,
      gv_appl          TYPE                   ole2_object,
      gv_wbooklist     TYPE                   ole2_object,
      gv_range         TYPE                   ole2_object,
      gv_columns       TYPE                   ole2_object,
      gv_font          TYPE                   ole2_object,
      gv_rc            TYPE                   sysubrc.

DATA: gv_data(4096)    TYPE                   c,
      gt_data          LIKE TABLE OF          gv_data.

*&---------------------------------------------------------------------*
*&  Include           Z_DOWNLOAD_EXCEL
*&---------------------------------------------------------------------*
FORM f_output_excel USING pit_head  TYPE ANY TABLE
                          pit_table TYPE ANY TABLE
                          pi_fpath  TYPE rlgrap-filename.

  DATA: lv_fpath        TYPE          string,
        lv_field        TYPE          string,
        lv_visible      TYPE          i.

  CONSTANTS: lc_tab     TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.

  FIELD-SYMBOLS: <lfs_field> TYPE ANY,
                 <lfs_struc> TYPE ANY.


  lv_fpath = pi_fpath.

*  Create an Excel object and start Excel.
  CREATE OBJECT gv_appl 'EXCEL.APPLICATION'.
  IF sy-subrc NE 0.
    MESSAGE 'Error creating Excel application'(001) TYPE 'E'.
  ENDIF.

*  Create an Excel workbook Object.
  CALL METHOD OF gv_appl 'WORKBOOKS' = gv_wbooklist.
  lv_visible = 0.
  SET PROPERTY OF gv_appl 'VISIBLE' = lv_visible.
  GET PROPERTY OF gv_wbooklist 'Application'(002) = gv_appl .
  CALL METHOD OF gv_wbooklist 'Add' = gv_workbook.
  CALL METHOD OF gv_appl 'WORKSHEETS' = gv_sheet
    EXPORTING
    #1 = 1.
  CALL METHOD OF gv_sheet 'ACTIVATE'.

*Table Header
  LOOP AT pit_head ASSIGNING <lfs_struc>.
    CLEAR gv_data.

    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE <lfs_struc> TO <lfs_field>.
      IF sy-subrc IS NOT INITIAL.
        EXIT.
      ELSE.
        lv_field = <lfs_field>.
        CONCATENATE gv_data lv_field INTO gv_data SEPARATED BY lc_tab.
      ENDIF.
    ENDDO.

    SHIFT gv_data LEFT DELETING LEADING lc_tab.

    APPEND gv_data TO gt_data.
  ENDLOOP.

*Table Data
  LOOP AT pit_table ASSIGNING <lfs_struc>.
    CLEAR gv_data.

    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE <lfs_struc> TO <lfs_field>.
      IF sy-subrc IS NOT INITIAL.
        EXIT.
      ELSE.
        lv_field = <lfs_field>.
        CONCATENATE gv_data lv_field INTO gv_data SEPARATED BY lc_tab.
      ENDIF.
    ENDDO.

    SHIFT gv_data LEFT DELETING LEADING lc_tab.

    APPEND gv_data TO gt_data.
  ENDLOOP.

  PERFORM f_paste_excel USING gt_data 1 1.
  PERFORM f_format.
  PERFORM f_select_cell USING 1 1 1 1.

  GET PROPERTY OF gv_appl 'ActiveWorkbook' = gv_workbook.

  CALL METHOD OF gv_workbook 'SAVEAS'
    EXPORTING
    #1 = lv_fpath
    #2 = 56.

  IF sy-subrc IS INITIAL.
    MESSAGE 'File Downloaded'(003) TYPE 'S'.
  ENDIF.
  CALL METHOD OF gv_workbook 'CLOSE'.

  "Quit the file
  CALL METHOD OF gv_appl 'QUIT'.

  "Free them up
  FREE OBJECT: gv_appl,
               gv_wbooklist,
               gv_workbook,
               gv_sheet.

  CLEAR gv_data. REFRESH gt_data.
  " Export the empty internal table to clear the clipboard
  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data                 = gt_data[]
    CHANGING
      rc                   = gv_rc
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

ENDFORM.                    " F_OUTPUT_EXCEL
*&---------------------------------------------------------------------*
*&      Form  f_paste_excel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PIT_DATA    text
*      -->PI_ROW1    text
*      -->PI_COL1    text
*----------------------------------------------------------------------*
FORM f_paste_excel USING pit_data LIKE gt_data
                         pi_row1  TYPE i
                         pi_col1  TYPE i.

  " Export the empty internal table to clear the clipboard
  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data                 = pit_data[]
    CHANGING
      rc                   = gv_rc
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  PERFORM f_select_cell USING pi_row1 pi_col1 pi_row1 pi_col1.

  CALL METHOD OF gv_sheet 'Paste'.

ENDFORM.                          " F_PASTE_EXCEL
*&---------------------------------------------------------------------*
*&      Form  f_format
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_format.

  PERFORM f_set_bold_row USING 1 1 1 17.

  "Columns for first system
  PERFORM f_set_column_width USING: 'A:A' 34,
                                    'B:B' 7,
                                    'C:C' 17,
                                    'D:D' 19,
                                    'E:E' 19,
                                    'F:F' 17,
                                    'G:G' 19,
                                    'H:H' 19.

  "Columns for second system
  PERFORM f_set_column_width USING: 'J:J' 34,
                                    'K:K' 7,
                                    'L:L' 17,
                                    'M:M' 19,
                                    'N:N' 19,
                                    'O:O' 17,
                                    'P:P' 19,
                                    'Q:Q' 19.

ENDFORM.                          " F_format
*&---------------------------------------------------------------------*
*&      Form  f_set_bold_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PI_ROW1    text
*      -->PI_COL1    text
*----------------------------------------------------------------------*
FORM f_set_bold_row USING pi_row1 TYPE i
                          pi_col1 TYPE i
                          pi_row2 TYPE i
                          pi_col2 TYPE i.

*Table Header
  PERFORM f_select_cell USING pi_row1 pi_col1 pi_row2 pi_col2.

  CALL METHOD OF gv_range 'Font' = gv_font.
  SET PROPERTY OF gv_font 'Bold'(004) = 1.

ENDFORM.                          " f_set_bold_row
*&---------------------------------------------------------------------*
*&      Form  F_SET_COLUMN_WIDTH
*&---------------------------------------------------------------------*
FORM f_set_column_width USING pi_column
                              pi_width.

  CALL METHOD OF gv_appl 'Columns' = gv_columns
    EXPORTING
    #1 = pi_column.

  SET PROPERTY OF gv_columns 'ColumnWidth' = pi_width.

ENDFORM.                          " f_set_column_width
*&---------------------------------------------------------------------*
*&      Form  f_select_cell
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PI_ROW1    text
*      -->PI_COL1    text
*----------------------------------------------------------------------*
FORM f_select_cell USING pi_row1  TYPE i
                         pi_col1  TYPE i
                         pi_row2  TYPE i
                         pi_col2  TYPE i.

  " Paste the contents in the clipboard to the worksheet
  CALL METHOD OF gv_appl 'Cells' = gv_cell
    EXPORTING
    #1 = pi_row1
    #2 = pi_col1.

  " Paste the contents in the clipboard to the worksheet
  CALL METHOD OF gv_appl 'Cells' = gv_cell2
    EXPORTING
    #1 = pi_row2
    #2 = pi_col2.

  CALL METHOD OF gv_appl 'Range' = gv_range
    EXPORTING
    #1 = gv_cell
    #2 = gv_cell2.

  CALL METHOD OF gv_range 'Select'.

ENDFORM.                          " F_select_cell
