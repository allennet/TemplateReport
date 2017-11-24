<%@ Control Language="C#" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI.Editor" TagPrefix="tools" %>
<script type="text/javascript">
	Type.registerNamespace("Telerik.Web.UI.Widgets");

	Telerik.Web.UI.Widgets.CellProperties = function (element) {
		Telerik.Web.UI.Widgets.CellProperties.initializeBase(this, [element]);

		this._clientParameters = null;
		this._editorRef = null;
		this._tableToModify = null;
		this._cssText = "";
		this._idInput = null;
		this._imageCaller = null;
		this._spinBoxWidth = null;
		this._spinBoxHeight = null;
		this._colorPicker = null;
		this._classSelector = null;
		this._cellAlignmentSelector = null;
		this._tablePreviewControl = null;
		this._tableBorderControl = null;
		this._selectedCells = [];
	}

	Telerik.Web.UI.Widgets.CellProperties.prototype = {
		initialize: function () {
			Telerik.Web.UI.Widgets.CellProperties.callBaseMethod(this, "initialize");
			this._initializeChildren();

			var unitsData = this._heightUnit.get_itemData();
			var units = [];
			for (var i = 0; i < unitsData.length; i++) {
				units.push(unitsData[i].value);
			}
			this._reUnits = new RegExp(units.join("|") + "$", "i");
		},

		_initializeChildren: function () {
			this._spinBoxHeight = $find("SpinBoxHeight");
			this._spinBoxWidth = $find("SpinBoxWidth");
			this._cellAlignmentSelector = $find("CellAlignmentSelector");
			this._colorPicker = $find("ColorPicker");
			this._classSelector = $find("ClassSelector");
			this._imageCaller = $find("ImageCaller");
			this._idInput = $get("TableId");
			this._noTextWrapping = $get("CheckBoxNoTextWrapping");
			this._styleBuilder = $get("StyleBuilder");
			this._styleBuilder.innerHTML = localization["MoreCellStyling"];

			this._tablePreviewControl = new Telerik.Web.UI.Widgets.TablePreview();
			this._tablePreviewControl.set_previewHolder($get("CellProperties_PreviewTableHolder"));
			this._tablePreviewControl.set_allowMultiCellSelection(true);

			this._heightUnit = $find("CellHeightUnit");
			this._widthUnit = $find("CellWidthUnit");
		},

		clientInit: function (clientParameters) {
			this._clientParameters = clientParameters;
			if (clientParameters) {
				this._tableToModify = clientParameters.tableToModify;
			}

			this._editorRef = clientParameters.editor;

			this._imageCaller.set_editor(this._editorRef);

			this._cellAlignmentSelector.setTagName("TD");

			if (this._colorPicker._popupVisible) this._colorPicker.hide();
			this._colorPicker.set_items(clientParameters.Colors);
			this._colorPicker.set_addCustomColorText(localization["AddCustomColor"]);


			this._classSelector.set_showText(true);
			this._classSelector.set_clearclasstext(localization["ClearClass"]);
			this._classSelector.set_text(localization["ApplyClass"]);
			this._classSelector.set_items(clientParameters.CssClasses);
			this._classSelector.add_valueSelected(this._cssValueSelected);

			this._styleBuilderClickedDelegate = Function.createDelegate(this, this._styleBuilderClicked);

			$(this._styleBuilder).on("click", this._styleBuilderClickedDelegate);
			this._tablePreviewControl._onSelectedCellChanged = Function.createDelegate(this, this._onSelectedCellChanged);

			this._selectedCell = this._clientParameters.selectedCell;

			this._loadData();
		},

		_styleBuilderClicked: function (ev) {
			//Editor object is supplied to all dialogs in the dialog parameters
			var editor = this._clientParameters.editor;
			var callbackFunction = Function.createDelegate(this, function (sender, args) {
				var resulCell = args.get_value();
				this._cssText = resulCell.style.cssText;
			});
			//NEW: Use EditorCommandEventArgs
			var parameterCell = this._cellToModify.cloneNode(true);
			//this._update(parameterCell);
			var argument = new Telerik.Web.UI.EditorCommandEventArgs("StyleBuilder", null, parameterCell);

			Telerik.Web.UI.Editor.CommandList._getDialogArguments(argument, "*", editor, "StyleBuilder");
			argument.fontNames = editor.get_fontNames();
			editor.showDialog("StyleBuilder", argument, callbackFunction);

			ev.preventDefault();
		},

		_cssValueSelected: function (oTool, args) {
			if (!oTool) return;
			var commandName = oTool.get_name();

			if ("ApplyClass" == commandName) {
				var attribValue = oTool.get_selectedItem();
				oTool.updateValue(attribValue);
			}
		},

		_setCssPropertyValue: function (element, cssProperty, value, attribute) {
			if (!element || !cssProperty) return;
			if (attribute) element.removeAttribute(attribute);
			element.style[cssProperty] = value;
		},

		_loadData: function (cellToLoad) {
			var cell = cellToLoad || this._cellToModify;
			if (cell) {
				this._cssText = cell.style.cssText;

				this._idInput.value = cell.getAttribute("id") ? cell.getAttribute("id") : "";

				if (this._imageCaller) {
					var imagePath = cell.style.backgroundImage;
					imagePath = (!imagePath) ? "" : imagePath.substring(4, imagePath.length - 1);
					this._imageCaller.set_value(imagePath);
				}

				var cellStyle = cell.style;
				var cellWidth = cellStyle.width ? cellStyle.width : cell.getAttribute("width");
				var cellHeight = cellStyle.height ? cellStyle.height : cell.getAttribute("height");

				if (cellWidth && !this._reUnits.test(cellWidth)) {
					cellWidth = cell.offsetWidth + "px";
				}

				if (cellHeight && !this._reUnits.test(cellHeight)) {
					cellHeight = cell.offsetHeight + "px";
				}

				this._setSize(cellHeight, this._spinBoxHeight, this._heightUnit);
				this._setSize(cellWidth, this._spinBoxWidth, this._widthUnit);

				var backgroundColor = cell.style.backgroundColor;
				this._colorPicker.set_color(backgroundColor);

				if (cell.className) this._classSelector.updateValue(cell.className);

				var textAlign = cell.style["textAlign"];
				var verticalAlign = cell.style["verticalAlign"];
				var alignAttributeValue = cell.getAttribute("align");
				var vAlignAttributeValue = cell.getAttribute("vAlign");

				if ((textAlign == "left" || textAlign == "center" || textAlign == "right") && (verticalAlign == "top" || verticalAlign == "middle" || verticalAlign == "bottom"))
					this._cellAlignmentSelector.updateValue(textAlign, verticalAlign);
				else if (alignAttributeValue || vAlignAttributeValue)
					this._cellAlignmentSelector.updateValue(alignAttributeValue, vAlignAttributeValue);
				else
					this._cellAlignmentSelector.updateValue(null, null);

				this._noTextWrapping.checked = cell.style.whiteSpace == "nowrap";

				this._tablePreviewControl.deSelectAllCells();
				this._selectedCell = cell;

				var table = $telerik.$(cell).closest("table").get(0);
				this._tablePreviewControl._updateTable(table, cell);
			}
		},

		_setSize: function (size, sizeControl, unitControl) {
			size = size || "";
			var unitMatch = size.match(this._reUnits);
			var unitItem = unitControl.findItemByValue(unitMatch ? unitMatch[0].toLowerCase() : "px");

			unitItem.set_selected(true);
			sizeControl.set_value(size ? parseFloat(size) : size);
		},

		_onSelectedCellChanged: function () {

		},

		_updateMultiple: function (cells) {
			for (var i = 0; i < cells.length; i++) {
				if (!this._updateCell(cells[i])) {
					return false;
				}
			}
			return true;
		},

		//TEKI - Shortened this method 2 times + fixed a problem with setting width and height
		_updateCell: function (cell) {
			if (!cell) {
				return false;
			}

			this._cellToModify = cell;

			cell.style.cssText = this._cssText;

			//This must be set on top - before all else, because it is interfering with the style.width and style.height stuff
			if (cell.style.cssText == '') {
				cell.removeAttribute('style', false);
			}

			var theWidthValue = this._spinBoxWidth.get_value();
			if (this._isValueValid(theWidthValue)) {
				cell.style.width = theWidthValue ? parseFloat(theWidthValue) + this._widthUnit.get_selectedItem().get_value() : "";
			}

			var theHeightValue = this._spinBoxHeight.get_value();
			if (this._isValueValid(theHeightValue)) {
				cell.style.height = theHeightValue ? parseFloat(theHeightValue) + this._heightUnit.get_selectedItem().get_value() : "";
			}

			this._setAttribValue("id", this._idInput.value);

			this._setCssPropertyValue(cell, "textAlign", this._cellAlignmentSelector.getAlign(), "align");
			this._setCssPropertyValue(cell, "verticalAlign", this._cellAlignmentSelector.getVAlign(), "vAlign");

			var color = this._colorPicker.get_color();
			if (cell.style["backgroundColor"] != color) {
				this._setCssPropertyValue(cell, "backgroundColor", color, "bgColor");
			}

			var backgroundImage = this._imageCaller.get_value();
			backgroundImage = (backgroundImage) ? "url(" + backgroundImage + ")" : "";
			this._setCssPropertyValue(cell, "backgroundImage", backgroundImage, "background");

			cell.className = this._classSelector.get_value();

			var whiteSpaceValue = (this._noTextWrapping.checked) ? "nowrap" : "";
			this._setCssPropertyValue(cell, "whiteSpace", whiteSpaceValue, "noWrap");

			return true;
		},

		_isValueValid: function (value) {
			var valueInt = parseFloat(value, 10);
			if (!isNaN(valueInt)) {
				//NEW support for all css units
				var isValidPercent = (valueInt + '%' == value);
				var isValidPixel = (valueInt + 'px' == value.toLowerCase());
				var isValidEm = (valueInt + 'em' == value.toLowerCase());
				var isValidEx = (valueInt + 'ex' == value.toLowerCase());
				var isValidIn = (valueInt + 'in' == value.toLowerCase());
				var isValidCm = (valueInt + 'cm' == value.toLowerCase());
				var isValidMm = (valueInt + 'mm' == value.toLowerCase());
				var isValidPt = (valueInt + 'pt' == value.toLowerCase());
				var isValidPc = (valueInt + 'pc' == value.toLowerCase());
				var isValidNumber = (valueInt.toString() == value);

				if (isValidPercent || isValidPixel || isValidEm || isValidEx || isValidIn || isValidCm || isValidMm || isValidPt || isValidPc || isValidNumber) {
					return true;
				}
			}
			return false;
		},

		_convertIntToPixel: function (oVal) {
			var oNew = "" + oVal;

			if (oNew.indexOf("%") != -1) {
				return oNew;
			}
			else {
				var arMatch = oNew.match(/(em|ex|px|in|cm|mm|pt|pc)$/); //NEW support for all css units
				oNew = parseFloat(oNew);
				if (!isNaN(oNew)) {
					oNew = (arMatch) ? oNew + arMatch[0] : oNew + "px"; //NEW support for all css units
					return oNew;
				}
			}
			return oVal;
		},

		_setAttribValue: function (attribName, oVal, forceVal) {
			if (oVal || (true == forceVal))//cellSpacing or cellPadding have by default 1 so we might want to set it to 0
			{
				this._cellToModify.setAttribute(attribName, oVal);
			}
			else {
				this._cellToModify.removeAttribute(attribName, false);
			}
		},

		set_tableToModify: function (value) {
			this._tableToModify = value;
		},

		set_cellToModify: function (value) {
			this._cellToModify = value;
			this._loadData();
		},

		dispose: function () {
			this._clientParameters = null;
			this._editorRef = null;
			this._tableToModify = null;
			this._cssText = null;
			this._idInput = null;
			this._imageCaller = null;
			this._spinBoxWidth = null;
			this._spinBoxHeight = null;
			this._colorPicker = null;
			this._classSelector = null;
			this._cellAlignmentSelector = null;
			this._tablePreviewControl = null;
			this._tableBorderControl = null;
			this._selectedCells = null;

			Telerik.Web.UI.Widgets.CellProperties.callBaseMethod(this, "dispose");
		}
	}

	Telerik.Web.UI.Widgets.CellProperties.registerClass('Telerik.Web.UI.Widgets.CellProperties', Telerik.Web.UI.RadWebControl, Telerik.Web.IParameterConsumer);
</script>

<div class="redInlineBlock redBlockLeft redTableWizard">
	<span class="rfdAspLabel rfdAspTitle redInlineBlock">
		<script type="text/javascript">document.write(localization["Preview"]);</script>
	</span>

	<div id="CellProperties_PreviewTableHolder" class="reTableDesignPreviewTableHolder reCellProperies">
		<!-- / -->
	</div>
</div>

<div class="redInlineBlock redBlockRight redTableWizard">
	<div class="redSection redSectionNoBorder">

		<div class="redRow">
			<label class="redLabel">
				<script type="text/javascript">document.write(localization["Height"]);</script>
			</label>
			<span class="redInlineBlock redMiddle">
				<tools:EditorSpinBox ID="SpinBoxHeight" runat="server"></tools:EditorSpinBox>
			</span>
			<span class="redInlineBlock redMiddle redDropDownShort reUnitDropdown">
				<telerik:RadDropDownList runat="server" ID="CellHeightUnit">
					<Items>
						<telerik:DropDownListItem Text="px" Value="px" />
						<telerik:DropDownListItem Text="%" Value="%" />
						<telerik:DropDownListItem Text="pt" Value="pt" />
					</Items>
				</telerik:RadDropDownList>
			</span>
		</div>

		<div class="redRow">
			<label class="redLabel">
				<script type="text/javascript">document.write(localization["Width"]);</script>
			</label>
			<span class="redInlineBlock redMiddle">
				<tools:EditorSpinBox ID="SpinBoxWidth" runat="server"></tools:EditorSpinBox>
			</span>
			<span class="redInlineBlock redMiddle redDropDownShort reUnitDropdown">
				<telerik:RadDropDownList runat="server" ID="CellWidthUnit">
					<Items>
						<telerik:DropDownListItem Text="px" Value="px" />
						<telerik:DropDownListItem Text="%" Value="%" />
						<telerik:DropDownListItem Text="pt" Value="pt" />
					</Items>
				</telerik:RadDropDownList>
			</span>
		</div>

		<div class="redRow">
			<label class="redLabel">
				<script type="text/javascript">document.write(localization["Alignment"]);</script>
			</label>
			<span class="redInlineBlock redMiddle redToolSplitButton">
				<tools:AlignmentSelector ID="CellAlignmentSelector" runat="server"></tools:AlignmentSelector>
			</span>
		</div>

		<div class="redRow">
			<label class="redLabel">
				<script type="text/javascript">document.write(localization["BackgroundColor"]);</script>
			</label>
			<span class="redInlineBlock redMiddle redToolSplitButton">
				<tools:ColorPicker ID="ColorPicker" runat="server"></tools:ColorPicker>
			</span>
		</div>

		<div class="redRow">
			<label class="redLabel">
				<script type="text/javascript">document.write(localization["CssClass"])</script>
			</label>
			<span class="redInlineBlock redMiddle redToolSplitButton">
				<tools:ApplyClassDropDown ID="ClassSelector" runat="server" />
			</span>
		</div>

		<div class="redRow">
			<label class="redLabel">
				<script type="text/javascript">document.write(localization["BackgroundImage"]);</script>
			</label>
			<span class="redInlineBlock redMiddle redToolSplitButton reSingleIcon">
				<tools:ImageDialogCaller ID="ImageCaller" runat="server"></tools:ImageDialogCaller>
			</span>
		</div>

		<div class="redRow">
			<label class="redLabel">
				<script type="text/javascript">document.write(localization["Id"]);</script>
			</label>
			<span class="redInlineBlock redMiddle redToolSplitButton">
				<input type="text" id="TableId" value="" />
			</span>
		</div>

		<div class="redRow">
			<label class="redLabel">
			</label>
			<span class="redInlineBlock redMiddle">
				<asp:CheckBox ID="CheckBoxNoTextWrapping" runat="server" 
					Text="<script type='text/javascript'>document.write(localization['NoTextWrapping']);</script>" />
			</span>
		</div>

		<div class="redRow">
			<label class="redLabel">
			</label>
			<span class="redInlineBlock redMiddle redToolSplitButton">
				<span class="redStyleBuilderButton">
					<button id="StyleBuilder">More Cell Styling...</button>
				</span>
			</span>
		</div>
	</div>
</div>
