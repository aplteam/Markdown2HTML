:Namespace  Markdown2HTML
⍝ Designed to convert either a single file or all files in a directory from *.md to *.html
⍝ Needs a directory "Markdown2HTML" where the user command lives holding the workspace and
⍝ the CSS files needed for the conversion.
⍝ The main purpose of this user command is to be called by a Make process when Markdown files
⍝ need to be converted into HTML files for the final package.
⍝ Kai Jaeger
⍝ Version 0.0.18 from 2017-07-29
⍝ * Now honours any .Markdown2HTML file

    ∇ r←List;⎕IO;⎕ML
      ⎕IO←⎕ML←1
      r←⎕NS¨2⍴⊂''
      r.Name←'Markdown2HTML' 'Markdown2HTMLConfigFile'
      r[1].Desc←⊂'Takes the name of a Markdown file or a directory holding *.md files and converts it/them to HTML5.'
      r[2].Desc←⊂'Creates a config file for the ]Markdown2HTML user command and returns its name.'
      r.Group←⊂'APLTree'
     ⍝ Parsing rules:
      r[1].Parse←'1 -configfile='
      r[2].Parse←'-filename='
    ∇

    ∇ r←Run(Cmd Args);home;rf
    ⍝ Work horse. Returns a list with all files converted.
      r←0 2⍴''
      home←↑⎕NPARTS ##.SourceFile
      :If 9=⎕SE.⎕NC'acre'
      :AndIf (⊂'#._Markdown2HTML')∊{⍵[;1]}⎕SE.UCMD'acre.Projects'
          rf←#._Markdown2HTML
      :Else
          rf←⎕SE.⎕NS''
          rf.⎕CY home,'Markdown2HTML\Markdown2HTML'
      :EndIf
      :Select Cmd
      :Case 'Markdown2HTML'
          r←Process rf Args
      :Case 'Markdown2HTMLConfigFile'
          r←CreateConfigFile rf
      :EndSelect
    ∇

    ∇ r←CreateConfigFile rf
      r←rf.Markdown2HTML.CreateConfigFile''
    ∇

    ∇ r←Process(rf Args);filenames;path;cssParms;css;msg;arg;success;buff;target;parms;errMsgs;configFile
      r←0 2⍴''
      arg←↑Args.Arguments
      :If rf.FilesAndDirs.IsDir{~'*'∊⍵:⍵ ⋄ ↑1 ⎕NPARTS ⍵}arg
          :If '*'∊arg
              filenames←↑rf.FilesAndDirs.Dir arg
          :Else
              filenames←↑rf.FilesAndDirs.Dir arg,'\*.md'
          :EndIf
          :If 0∊⍴filenames
              :Return
          :Else
              path←arg
              filenames←2⊃¨⎕SE.APLTreeUtils.SplitPath¨filenames
              path←{1 ⎕NPARTS''}⍣(0∊⍴path)⊣path
              :If '*'∊path
                  path←↑1 ⎕NPARTS path
              :EndIf
          :EndIf
      :Else
          (path filenames)←rf.APLTreeUtils.SplitPath↑Args.Arguments
          path←{↑1 ⎕NPARTS''}⍣(0∊⍴path)⊣path
          filenames,←(~'.'∊filenames)/'.md'
          :If 0=⎕NEXISTS path,'\',filenames
              'File does not exist'⎕SIGNAL 6
          :EndIf
          filenames←rf.APLTreeUtils.Nest filenames
      :EndIf
      path↓⍨←-(¯1↑path)∊'/\'
      target←path
      :If ⎕NEXISTS path,'\.Markdown2HTML'
      :AndIf ~0∊⍴buff←'flat'rf.APLTreeUtils.ReadUtf8File path,'\.Markdown2HTML'
      :AndIf 'outputPath'{⍺≡(⍴,⍺)↑⍵}buff
          buff←¯1↓1↓rf.APLTreeUtils.dmb{⍵↓⍨⍵⍳'='}buff
          :If '..'≢2⍴buff
              target←'expand'rf.FilesAndDirs.NormalizePath buff
          :Else
              target←'expand'rf.FilesAndDirs.NormalizePath target,'\',buff
          :EndIf
      :EndIf
      :If (,0)≡,configFile←Args.Switch'configfile'
          parms←rf.MarkAPL.CreateParms
      :Else
          parms←GetParmsFromConfigFile configFile
      :EndIf
      :If parms.cssURL≡⎕NULL
          parms.cssURL←rf.FilesAndDirs.PWD
      :EndIf
      (success msg errMsgs)←parms rf.Markdown2HTML.ProcessFiles filenames path target
      r←success,[1.5]msg
    ∇

    ∇ parms←GetParmsFromConfigFile filename;buff;bool
⍝ `filename` is the name of a config file, typically created by calling MarkAPL.CreateParms
⍝ and then converting the result into JSON.
⍝ The JSON in the file will be converted to an APL array with any char vector `[Null]` becoming ⎕NULL.
      buff←rf.APLTreeUtils.ReadUtf8File filename
      :If 15=↑(//)⎕VFI{⍵/⍨2>+\⍵='.'}2⊃'#'⎕WG'APLVersion'
          buff←⊃{(7159⌶)⍵}¨buff
      :Else
          buff←⊃{⎕JSON ⍵}¨buff
      :EndIf
      :If ∨/bool←'[Null]'∘≡¨buff[;2]
          (bool⌿buff[;2])←⎕NULL
      :EndIf
      parms←⎕NS''
      parms.{⎕NULL≡⍵:⍎⍺,'←⎕NULL' ⋄ 0=1↑0⍴⍵:⍎⍺,'←',⍕⍵ ⋄ ⍎⍺,'←''',⍵,''''}/¨↓buff
      parms.⎕FX'r←∆List;⎕IO' '⍝ List all variables and possible references in this namespace' '⎕IO←1' 'r←{⍵,[1.5]⍎¨⍵}⎕NL-2 9'
     ⍝Done
    ∇

    ∇ r←level Help Cmd;⎕IO;⎕ML
      ⎕IO←1 ⋄ ⎕ML←1
      r←''
      :Select Cmd
      :Case 'Markdown2HTMLConfigFile'
          r,←⊂'Creates a config file; this is a JSON version of what MarkAPL.CreateParms creates.'
          r,←⊂'The config file is created in the TEMP folder.'
          r,←⊂'The filename is returned as result.'
      :Case 'Markdown2HTML'
          :Select ⊃level
          :CaseList 0 1 2
              r←''
              r,←⊂'Takes one of:'
              r,←⊂' * The name of a Markdown file;'
              r,←⊂'   That file is then converted into an HTML file.'
              r,←⊂' * The name of a folder holding Markdown files;'
              r,←⊂'   All Markdown files in that folder are converted into HTML files.'
              r,←⊂''
              r,←⊂'If the filename has no extension then ".md" is assumed.'
              r,←⊂'For a folder you can, say, specify C:\MyFiles\*.markdown.'
              r,←⊃'Note that you can only specify one extension.'
              r,←⊂''
              r,←⊂'The output filename is the same as the input filename except that'
              r,←⊂'the extension will become ".html".'
              r,←⊂''
              r,←⊂'The User Command returns a matrix with two columns:'
              r,←⊂'* [;1] = Boolean (1=success)'
              r,←⊂'* [;2] = Output filename'
          :EndSelect
      :EndSelect
    ∇

:EndNamespace