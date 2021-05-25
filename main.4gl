IMPORT reflect
IMPORT FGL fgldialog
IMPORT FGL g2m_ui

SCHEMA njm_demo310
DEFINE m_cst RECORD
	cst     RECORD LIKE customer.*,
	del_add RECORD LIKE addresses.*,
	inv_add RECORD LIKE addresses.*
END RECORD
DEFINE m_ui g2m_ui
MAIN

	TRY
		DATABASE njm_demo310
	CATCH
		CALL fgl_winMessage("DB Error", SQLERRMESSAGE, "exclamation")
		EXIT PROGRAM
	END TRY

	OPEN FORM f FROM "form"
	DISPLAY FORM f

	SELECT * INTO m_cst.cst.* FROM customer WHERE customer_code = "C0001"
	SELECT * INTO m_cst.del_add.* FROM addresses WHERE rec_key = m_cst.cst.del_addr
	SELECT * INTO m_cst.inv_add.* FROM addresses WHERE rec_key = m_cst.cst.inv_addr

	DISPLAY m_cst.cst.* TO customer.*
	DISPLAY m_cst.del_add.* TO addresses.*
	DISPLAY m_cst.inv_add.* TO formonly.*

	CALL m_ui.init("customers", reflect.Value.valueOf(m_cst))

	MENU
		ON ACTION update
			CALL cst_update()
		ON ACTION quit
			EXIT PROGRAM
		ON ACTION close
			EXIT PROGRAM
	END MENU

END MAIN
--------------------------------------------------------------------------------
FUNCTION cst_update()
	IF m_ui.inp(FALSE) THEN
		DISPLAY "Record updated."
		CALL m_ui.getRecord(reflect.Value.valueOf(m_cst))
		DISPLAY "Customer Name: ", m_cst.cst.customer_name
		DISPLAY "Del PC: ", m_cst.del_add.postal_code
	ELSE
		DISPLAY "Nothing changed."
	END IF
END FUNCTION
