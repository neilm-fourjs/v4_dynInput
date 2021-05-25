IMPORT reflect

TYPE t_fieldList DYNAMIC ARRAY OF RECORD
	nam    STRING,
	typ    STRING,
	defVal STRING,
	val    STRING
END RECORD

PUBLIC TYPE g2m_ui RECORD
	uiName STRING,
	fields t_fieldList,
	fcnt   SMALLINT,
	dia    ui.Dialog
END RECORD

--------------------------------------------------------------------------------
-- Initialize the UI objects
-- @param l_nam of UI
FUNCTION (this g2m_ui) init(l_nam STRING, l_r_val reflect.Value)
	DEFINE i SMALLINT
	LET this.uiName = l_nam
	CALL this.initFields(0, "mainValue", l_r_val, TRUE)
	DISPLAY "Field List:"
	FOR i = 1 TO this.fcnt
		DISPLAY this.fields[i].nam, " ", this.fields[i].typ
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
-- @param l_new Is new record
FUNCTION (this g2m_ui) inp(l_new BOOLEAN)
	DEFINE x            SMALLINT
	DEFINE l_evt, l_fld STRING
	DISPLAY "Input"
	CALL ui.Dialog.setDefaultUnbuffered(TRUE)

	LET this.dia = ui.Dialog.createInputByName(this.fields)

	FOR x = 1 TO this.fields.getLength()
		IF l_new THEN
			CALL this.dia.setFieldValue(this.fields[x].nam, this.fields[x].defVal)
		ELSE
			CALL this.dia.setFieldValue(this.fields[x].nam, this.fields[x].val)
		END IF
	END FOR

	CALL this.dia.addTrigger("ON ACTION accept")
	CALL this.dia.addTrigger("ON ACTION cancel")
	CALL this.dia.addTrigger("ON ACTION close")
	LET int_flag = FALSE
	WHILE TRUE
		LET l_evt = this.dia.nextEvent()
		LET l_fld = this.dia.getCurrentItem()
		IF l_evt.subString(1, 11) = "AFTER FIELD" THEN
--			LET l_fld = l_evt.subString(13, l_evt.getLength())
			LET l_evt = "AFTER FIELD"
		END IF
		IF l_evt.subString(1, 9) = "ON CHANGE" THEN
--			LET l_fld = l_evt.subString(11, l_evt.getLength())
			LET l_evt = "ON CHANGE"
		END IF
		DISPLAY SFMT("Event: %1 Field: %2", l_evt, l_fld)
		CASE l_evt
			WHEN "ON ACTION close"
				LET int_flag = TRUE
				EXIT WHILE
			WHEN "ON ACTION accept"
				EXIT WHILE
			WHEN "ON ACTION cancel"
				LET int_flag = TRUE
				EXIT WHILE
		END CASE
	END WHILE
END FUNCTION
--------------------------------------------------------------------------------
-- Initialize the field list
-- @param l_lev debug nested level
-- @param l_nam record name
-- @param l_rv Reflect Value
-- @param l_debug display to terminal
FUNCTION (this g2m_ui) initFields(l_lev SMALLINT, l_nam STRING, l_rv reflect.value, l_debug BOOLEAN)
	DEFINE i    SMALLINT
	DEFINE l_rt reflect.type
	LET l_rt = l_rv.getType()
	FOR i = 1 TO l_rt.getFieldCount()
		IF l_debug THEN
			DISPLAY SFMT("%1%2 %3 %4 (%5) : %6",
					l_lev SPACES, l_nam, l_rt.getFieldName(i), l_rt.getFieldType(i).toString(), l_rt.getFieldType(i).getKind(),
					l_rv.getField(i).toString())
		END IF
		IF l_rt.getFieldType(i).getKind() = "RECORD" THEN
			CALL this.initFields(l_lev + 2, l_rt.getFieldName(i), l_rv.getField(i), l_debug)
		END IF
		IF l_rt.getFieldType(i).getKind() = "PRIMITIVE" THEN
			LET this.fields[this.fcnt := this.fcnt + 1].nam = l_nam.trim() || "." || l_rt.getFieldName(i)
			LET this.fields[this.fcnt].typ                  = l_rt.getFieldType(i).toString()
			LET this.fields[this.fcnt].val                  = l_rv.getField(i).toString()
			LET this.fields[this.fcnt].defVal               = ""
		END IF
	END FOR
END FUNCTION
