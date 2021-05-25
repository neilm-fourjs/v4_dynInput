IMPORT reflect
IMPORT FGL fgldialog
IMPORT FGL g2m_ui

SCHEMA njm_demo310
DEFINE m_stk RECORD LIKE stock.*
DEFINE m_ui g2m_ui
MAIN

	TRY
		CONNECT TO "njm_demo310.db"
	CATCH
		CALL fgl_winMessage("DB Error", SQLERRMESSAGE, "exclamation")
		EXIT PROGRAM
	END TRY

	OPEN FORM f FROM "stkmnt"
	DISPLAY FORM f

	SELECT * INTO m_stk.* FROM stock WHERE stock_code = "FR01"
	DISPLAY m_stk.* TO stock.*

	CALL m_ui.init("stock", reflect.Value.valueOf(m_stk))

	MENU
		ON ACTION update
			CALL updateRow()
		ON ACTION quit
			EXIT PROGRAM
		ON ACTION close
			EXIT PROGRAM
	END MENU

END MAIN
--------------------------------------------------------------------------------
FUNCTION updateRow()
	IF m_ui.inp(FALSE) THEN
		DISPLAY "Record updated."
		CALL m_ui.getRecord(reflect.Value.valueOf(m_stk))
		DISPLAY "Stock Description: ", m_stk.description
	ELSE
		DISPLAY "Nothing changed."
	END IF
END FUNCTION
