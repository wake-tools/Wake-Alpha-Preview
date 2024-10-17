#include "TextEditor.h"
#include "cTextEditor.h"

CIMGUI_API TextEditor* ImEdit_New(){
   return new TextEditor();
}
CIMGUI_API void ImEdit_Delete(TextEditor* e){
   e->Delete();
   delete e;  
}
CIMGUI_API TextEditor::Coordinates ImEdit_GetCursorPosition(TextEditor* e){
   return e->GetCursorPosition();
}
CIMGUI_API void ImEdit_SetText(TextEditor* e, char* text){
   e->SetText(std::string(text));
}
CIMGUI_API const char* ImEdit_GetText(TextEditor* e, TextEditor::Coordinates start, TextEditor::Coordinates end){
   if(end.mLine == 0 && end.mColumn==0)end.mLine = e->mLines.size();
   return e->GetText(start, end).c_str();
}
//
CIMGUI_API void ImEdit_SetReadOnly(TextEditor* e, bool value){
	e->SetReadOnly(value);
}
CIMGUI_API bool ImEdit_IsReadOnly(TextEditor* e){
	return e->IsReadOnly();
}
CIMGUI_API bool ImEdit_IsTextChanged(TextEditor* e){
	return e->IsTextChanged();
}
CIMGUI_API bool ImEdit_IsCursorPositionChanged(TextEditor* e){
	return e->IsCursorPositionChanged();
}
CIMGUI_API bool ImEdit_IsColorizerEnabled(TextEditor* e){
	return e->IsColorizerEnabled();
}
CIMGUI_API void ImEdit_SetColorizerEnable(TextEditor* e, bool value){
   e->SetColorizerEnable(value);
}
CIMGUI_API void ImEdit_SetCursorPosition(TextEditor* e, TextEditor::Coordinates pos){
	e->SetCursorPosition(pos);
}

CIMGUI_API void ImEdit_SetHandleMouseInputs(TextEditor* e, bool value){
	return e->SetHandleMouseInputs(value);
}
CIMGUI_API bool ImEdit_IsHandleMouseInputsEnabled(TextEditor* e){
	return e->IsHandleMouseInputsEnabled();
}

CIMGUI_API void ImEdit_SetHandleKeyboardInputs(TextEditor* e, bool value){
	return e->SetHandleKeyboardInputs(value);
}
CIMGUI_API bool ImEdit_IsHandleKeyboardInputsEnabled(TextEditor* e){
	return e->IsHandleKeyboardInputsEnabled();
}

CIMGUI_API void ImEdit_SetImGuiChildIgnored(TextEditor* e, bool value){
	return e->SetImGuiChildIgnored(value);
}
CIMGUI_API bool ImEdit_IsImGuiChildIgnored(TextEditor* e){
	return e->IsImGuiChildIgnored();
}

CIMGUI_API void ImEdit_SetShowWhitespaces(TextEditor* e, bool value){
	return e->SetShowWhitespaces(value);
}
CIMGUI_API bool ImEdit_IsShowingWhitespaces(TextEditor* e){
	return e->IsShowingWhitespaces();
}

CIMGUI_API void ImEdit_SetTabSize(TextEditor* e, int value){
	return e->SetTabSize(value);
}
CIMGUI_API int ImEdit_GetTabSize(TextEditor* e){
	return e->GetTabSize();
}
CIMGUI_API void ImEdit_InsertText(TextEditor* e, char* text){
   e->InsertText(text);
}

CIMGUI_API void ImEdit_MoveUp(TextEditor* e, int aAmount = 1, bool aSelect = false){
   e->MoveUp(aAmount, aSelect);
}
CIMGUI_API void ImEdit_MoveDown(TextEditor* e, int aAmount = 1, bool aSelect = false){
   e->MoveDown(aAmount, aSelect);
}
CIMGUI_API void ImEdit_MoveLeft(TextEditor* e, int aAmount = 1, bool aSelect = false, bool aWordMode = false){
   e->MoveLeft(aAmount, aSelect, aWordMode);
}
CIMGUI_API void ImEdit_MoveRight(TextEditor* e, int aAmount = 1, bool aSelect = false, bool aWordMode = false){
   e->MoveRight(aAmount, aSelect, aWordMode);
}
CIMGUI_API void ImEdit_MoveTop(TextEditor* e, bool aSelect = false){
   e->MoveTop(aSelect);
}
CIMGUI_API void ImEdit_MoveBottom(TextEditor* e, bool aSelect = false){
   e->MoveBottom(aSelect);
}
CIMGUI_API void ImEdit_MoveHome(TextEditor* e, bool aSelect = false){
   e->MoveHome(aSelect);
}
CIMGUI_API void ImEdit_MoveEnd(TextEditor* e, bool aSelect = false){
   e->MoveEnd(aSelect);
}


CIMGUI_API void ImEdit_SetSelectionStart(TextEditor* e, TextEditor::Coordinates aPosition){
   e->SetSelectionStart(aPosition);
}
CIMGUI_API void ImEdit_SetSelectionEnd(TextEditor* e, TextEditor::Coordinates aPosition){
   e->SetSelectionEnd(aPosition);
}

CIMGUI_API void ImEdit_SetSelection(TextEditor* e, TextEditor::Coordinates  aStart, TextEditor::Coordinates aEnd, TextEditor::SelectionMode aMode =  TextEditor::SelectionMode::Normal){
   e->SetSelection(aStart, aEnd, aMode);
}

CIMGUI_API void ImEdit_SelectAll(TextEditor* e){
   e->SelectAll();
}
CIMGUI_API bool ImEdit_HasSelection(TextEditor* e){
   return e->HasSelection();
}
CIMGUI_API void ImEdit_Copy(TextEditor* e){
   e->Copy();
}
CIMGUI_API void ImEdit_Cut(TextEditor* e){
   e->Cut();
}
CIMGUI_API void ImEdit_Paste(TextEditor* e){
   e->Paste();
}
CIMGUI_API void ImEdit_Remove(TextEditor* e){
   e->Delete();
}

CIMGUI_API bool ImEdit_IsOverwrite(TextEditor* e){
   return e->IsOverwrite();
}
CIMGUI_API bool ImEdit_CanUndo(TextEditor* e){
   return e->CanUndo();
}
CIMGUI_API bool ImEdit_CanRedo(TextEditor* e){
   return e->CanRedo();
}

CIMGUI_API void ImEdit_Undo(TextEditor* e, int aSteps = 1){
   e->Undo(aSteps);
}
CIMGUI_API void ImEdit_Redo(TextEditor* e, int aSteps = 1){
   e->Redo(aSteps);
}


CIMGUI_API void ImEdit_Render(TextEditor* e, const char* aTitle, const ImVec2 aSize = ImVec2(), bool aBorder = false){
   e->Render(aTitle, aSize, aBorder);
}

//////////////////////////////////
//////////////////////////////////
//////////////////////////////////
CIMGUI_API void ImEdit_SetColor(TextEditor* e, ImEdit_Color index, ImU32 col){
   e->mPaletteBase[index]=col;
}
CIMGUI_API ImU32 ImEdit_GetColor(TextEditor* e, ImEdit_Color index){
   return e->mPaletteBase[index];
}
//////////////////////////////////
//////////////////////////////////
//////////////////////////////////
typedef std::vector< TextEditor::LanguageDefinition>  LanguageDefinitions;
LanguageDefinitions mLanguageDefinitions;

CIMGUI_API TextEditor::LanguageDefinition* ImEdit_GetLanguageDefinition(TextEditor* e, char* name){
   auto it = std::find_if(mLanguageDefinitions.begin(), mLanguageDefinitions.end(), [name](const TextEditor::LanguageDefinition& ld) { return ld.mName == name; });
   if (it != mLanguageDefinitions.end()) return &(*it);
   mLanguageDefinitions.emplace_back();
   auto& newLanguageDef = mLanguageDefinitions.back();
   newLanguageDef.mName = name; // Initialisation du nom du nouveau langage
   if(strcmp(name,"C")==0)newLanguageDef = TextEditor::LanguageDefinition::C(); 
   if(strcmp(name,"C++")==0)newLanguageDef = TextEditor::LanguageDefinition::CPlusPlus(); 
   if(strcmp(name,"HLSL")==0)newLanguageDef = TextEditor::LanguageDefinition::HLSL(); 
   if(strcmp(name,"GLSL")==0)newLanguageDef = TextEditor::LanguageDefinition::GLSL(); 
   if(strcmp(name,"SQL")==0)newLanguageDef = TextEditor::LanguageDefinition::SQL(); 
   if(strcmp(name,"AngelScript")==0)newLanguageDef = TextEditor::LanguageDefinition::AngelScript(); 
   if(strcmp(name,"Lua")==0)newLanguageDef = TextEditor::LanguageDefinition::Lua(); 
   return &newLanguageDef;
}
CIMGUI_API void ImEdit_ClearLanguageDefinitions() {
    for (auto& languageDef : mLanguageDefinitions) {
         languageDef.mKeywords.clear();
         languageDef.mIdentifiers.clear();
         languageDef.mPreprocIdentifiers.clear();
         languageDef.mTokenRegexStrings.clear();
         delete &languageDef;
    }
    mLanguageDefinitions.clear();
}
void ImEdit_SetLanguageDefinition(TextEditor* e, TextEditor::LanguageDefinition* lang){
   e->SetLanguageDefinition(*lang);
}
//////////////////////////////////
void ImEdit_AddPreprocIdentifiers(TextEditor::LanguageDefinition* lang,  char* name, char* value){
   TextEditor::Identifier id;
   id.mDeclaration = value;
   lang->mPreprocIdentifiers.insert(std::make_pair(std::string(name), id));
}
void ImEdit_ClearPreprocIdentifiers(TextEditor::LanguageDefinition* lang){
   lang->mPreprocIdentifiers.clear();
}
//
void ImEdit_AddIdentifiers(TextEditor::LanguageDefinition* lang,  char* name, char* value){
   TextEditor::Identifier id;
   id.mDeclaration = value;
   lang->mIdentifiers.insert(std::make_pair(std::string(name), id));
}
void ImEdit_ClearIdentifiers(TextEditor::LanguageDefinition* lang){
   lang->mIdentifiers.clear();
}
//
void ImEdit_AddKeywords(TextEditor::LanguageDefinition* lang,  char* name){
   lang->mKeywords.insert(std::string(name));
}
void ImEdit_ClearKeywords(TextEditor::LanguageDefinition* lang){
   lang->mKeywords.clear();
}
//
void ImEdit_AddErrorMarkers(TextEditor* e,  int line_number, char* error_info){
	e->mErrorMarkers.insert(std::make_pair( line_number, std::string(error_info)));
}
void ImEdit_ClearErrorMarkers(TextEditor* e){
	e->mErrorMarkers.clear();
}
//
void ImEdit_SetComment(TextEditor::LanguageDefinition* lang, char* single_line_comment, char* comment_start, char* comment_end){
   lang->mCommentStart = comment_start;
   lang->mCommentEnd = comment_end;
   lang->mSingleLineComment = single_line_comment;
}
//
void ImEdit_AddRegEx(TextEditor::LanguageDefinition* lang,  char* regex, ImEdit_Color index){
   lang->mTokenRegexStrings.push_back(std::make_pair<std::string, TextEditor::PaletteIndex>(std::string(regex), (TextEditor::PaletteIndex)index));
}
void ImEdit_ClearRegEx(TextEditor::LanguageDefinition* lang){
   lang->mTokenRegexStrings.clear();
}
//
void ImEdit_AddBreakpoint(TextEditor* e,  int line_number){
	e->mBreakpoints.insert(line_number);
}
void ImEdit_ClearBreakpoint(TextEditor* e){
	e->mBreakpoints.clear();
}
//