; Rugby League 26 Revamp installer (Inno Setup 6).
; Built by tools/package_revamp.py --installer, which passes:
;   /DSourceDir=<_dist/RL26-Revamp>   the packaged folder (runtime, toolchain, tools, mods, resources)
;   /DOutputDir=<_dist>
; The wizard copies that folder, then runs tools/install_revamp.py on the
; bundled Python with the options picked here; Windows' uninstall entry runs
; install_revamp.py --uninstall first, which puts the game back to stock.

#ifndef SourceDir
  #define SourceDir "..\..\_dist\RL26-Revamp"
#endif
#ifndef OutputDir
  #define OutputDir "..\..\_dist"
#endif
#define AppName "Rugby League 26 Revamp"

[Setup]
AppId={{A81DB6D6-8355-46A3-B6CD-80D111CDD981}
AppName={#AppName}
AppVersion=1.0
AppPublisher=Galaxsi Studios
; per-user and short: the tools write their work files next to themselves,
; and the game's deepest script paths need a short install path (260-char limit)
DefaultDirName={localappdata}\RL26Revamp
PrivilegesRequired=lowest
DisableProgramGroupPage=yes
OutputDir={#OutputDir}
OutputBaseFilename=RL26-Revamp-Setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName={#AppName}

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Tasks]
Name: "rll4"; Description: "I own Rugby League Live 4: bring over its jerseys"; Flags: unchecked
Name: "rll4\players"; Description: "Also import its face-scanned players (adds a long step to the install)"; Flags: unchecked
Name: "r25"; Description: "I own Rugby 25: install the Rugby 25 Expansion (animations, cutscenes)"; Flags: unchecked
Name: "skipintro"; Description: "Skip the boot splash screens"
Name: "icons"; Description: "Controller button icons:"
Name: "icons\detect"; Description: "Match my controller"; Flags: exclusive
Name: "icons\xbox"; Description: "Xbox"; Flags: exclusive unchecked
Name: "icons\ps5"; Description: "PlayStation 5"; Flags: exclusive unchecked
Name: "icons\ps4"; Description: "PlayStation 4"; Flags: exclusive unchecked

[UninstallDelete]
; work files rebuilt from the game; _backup\ (incl. save backups) is left in place
Type: filesandordirs; Name: "{app}\_build"
Type: filesandordirs; Name: "{app}\extracted"
Type: filesandordirs; Name: "{app}\decompiled"
Type: filesandordirs; Name: "{app}\manifests"
Type: filesandordirs; Name: "{app}\r25"

[Code]
var
  GamePage: TInputDirWizardPage;

{ Steam libraries, the same way tools/games.py finds them: Steam's own folder
  (registry) plus every "path" in its steamapps\libraryfolders.vdf. }
procedure AddLibrary(var Libs: TArrayOfString; Path: String);
var
  I: Integer;
begin
  StringChangeEx(Path, '/', '\', True);
  StringChangeEx(Path, '\\', '\', True);
  if Path = '' then Exit;
  for I := 0 to GetArrayLength(Libs) - 1 do
    if CompareText(Libs[I], Path) = 0 then Exit;
  SetArrayLength(Libs, GetArrayLength(Libs) + 1);
  Libs[GetArrayLength(Libs) - 1] := Path;
end;

function SteamLibraries: TArrayOfString;
var
  Libs, Roots, Lines: TArrayOfString;
  Root, Line: String;
  I, J, P: Integer;
begin
  SetArrayLength(Libs, 0);
  SetArrayLength(Roots, 0);
  if RegQueryStringValue(HKCU, 'Software\Valve\Steam', 'SteamPath', Root) then AddLibrary(Roots, Root);
  if RegQueryStringValue(HKLM, 'SOFTWARE\WOW6432Node\Valve\Steam', 'InstallPath', Root) then AddLibrary(Roots, Root);
  AddLibrary(Roots, ExpandConstant('{commonpf32}\Steam'));
  for I := 0 to GetArrayLength(Roots) - 1 do
  begin
    AddLibrary(Libs, Roots[I]);
    if LoadStringsFromFile(Roots[I] + '\steamapps\libraryfolders.vdf', Lines) then
      for J := 0 to GetArrayLength(Lines) - 1 do
      begin
        Line := Trim(Lines[J]);
        if Pos('"path"', Line) = 1 then
        begin
          Line := Trim(Copy(Line, 7, Length(Line)));       { "D:\\SteamLibrary" }
          Delete(Line, 1, 1);
          P := Pos('"', Line);
          if P > 0 then AddLibrary(Libs, Copy(Line, 1, P - 1));
        end;
      end;
  end;
  Result := Libs;
end;

{ The game's folder in the first library that has it (Marker = a file every
  install has, as in games.py), or '' when Steam doesn't have it. }
function FindGame(Folder, Marker: String): String;
var
  Libs: TArrayOfString;
  I: Integer;
begin
  Result := '';
  Libs := SteamLibraries;
  for I := 0 to GetArrayLength(Libs) - 1 do
    if FileExists(Libs[I] + '\steamapps\common\' + Folder + '\' + Marker) then
    begin
      Result := Libs[I] + '\steamapps\common\' + Folder;
      Exit;
    end;
end;

procedure InitializeWizard;
begin
  GamePage := CreateInputDirPage(wpSelectTasks, 'Game folders',
    'Where are your games installed?',
    'These were found in your Steam libraries - change them if a game is somewhere else. ' +
    'The game must be closed while installing.',
    False, '');
  GamePage.Add('Rugby League 26');
  GamePage.Add('Rugby League Live 4 (only used if ticked)');
  GamePage.Add('Rugby 25 (only used if ticked)');
  GamePage.Values[0] := FindGame('Rugby League', 'data\data-0.blobset.pc');
  GamePage.Values[1] := FindGame('Rugby League Live 4', 'data-0.blobset.pc');
  GamePage.Values[2] := FindGame('Rugby 25', 'data\data-0.blobset.pc');
end;

function CheckGame(Index: Integer; Name, Marker: String): Boolean;
begin
  Result := FileExists(AddBackslash(GamePage.Values[Index]) + Marker);
  if not Result then
    MsgBox(Name + ' wasn''t found in that folder. Pick the folder that has the game in it ' +
      '(Steam: right-click the game > Manage > Browse local files).', mbError, MB_OK);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (CurPageID = wpSelectDir) and (Length(WizardDirValue) > 60) then
  begin
    MsgBox('Please pick a shorter folder (60 characters or less): some of the game''s script paths are very long.',
      mbError, MB_OK);
    Result := False;
  end;
  if CurPageID = GamePage.ID then
  begin
    Result := CheckGame(0, 'Rugby League 26', 'data\data-0.blobset.pc');
    if Result and WizardIsTaskSelected('rll4') then
      Result := CheckGame(1, 'Rugby League Live 4', 'data-0.blobset.pc');
    if Result and WizardIsTaskSelected('r25') then
      Result := CheckGame(2, 'Rugby 25', 'data\data-0.blobset.pc');
  end;
end;

function Quote(S: String): String;
begin
  Result := '"' + S + '"';
end;

function InstallerArgs: String;
begin
  Result := '-E -s ' + Quote(ExpandConstant('{app}\tools\install_revamp.py')) + ' --confirm';
  if WizardIsTaskSelected('rll4') then Result := Result + ' --rll4' else Result := Result + ' --no-rll4';
  if WizardIsTaskSelected('rll4\players') then Result := Result + ' --rll4-players' else Result := Result + ' --no-rll4-players';
  if WizardIsTaskSelected('r25') then Result := Result + ' --r25' else Result := Result + ' --no-r25';
  if not WizardIsTaskSelected('skipintro') then Result := Result + ' --no-skip-intro';
  if WizardIsTaskSelected('icons\xbox') then Result := Result + ' --controller xbox'
  else if WizardIsTaskSelected('icons\ps5') then Result := Result + ' --controller ps5'
  else if WizardIsTaskSelected('icons\ps4') then Result := Result + ' --controller ps4'
  else Result := Result + ' --controller detect';
  if GamePage.Values[0] <> '' then Result := Result + ' --rl26-dir ' + Quote(GamePage.Values[0]);
  if GamePage.Values[1] <> '' then Result := Result + ' --rll4-dir ' + Quote(GamePage.Values[1]);
  if GamePage.Values[2] <> '' then Result := Result + ' --r25-dir ' + Quote(GamePage.Values[2]);
end;

function RunRevamp(Args: String; What: String): Boolean;
var
  Code: Integer;
begin
  Result := Exec(ExpandConstant('{app}\runtime\python.exe'), Args, ExpandConstant('{app}'), SW_SHOW,
                 ewWaitUntilTerminated, Code) and (Code = 0);
  if not Result then
    MsgBox(What + ' did not finish (exit code ' + IntToStr(Code) + ').' + #13#10 +
      'The log is ' + ExpandConstant('{app}\_build\install_revamp.log') + '.' + #13#10 +
      'Your saves were backed up to ' + ExpandConstant('{app}\_backup\saves') + ' first.', mbError, MB_OK);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    WizardForm.StatusLabel.Caption := 'Building and installing the Revamp into your game (this takes a while)...';
    RunRevamp(InstallerArgs, 'Installing the Revamp');
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
    if not RunRevamp('-E -s ' + Quote(ExpandConstant('{app}\tools\install_revamp.py')) + ' --uninstall --confirm',
                     'Putting the game back to stock') then
      MsgBox('Use Steam''s "Verify integrity of game files" on Rugby League 26 to finish restoring it.',
        mbInformation, MB_OK);
end;
