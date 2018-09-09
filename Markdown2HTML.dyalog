:Namespace  Markdown2HTML
⍝ Designed to convert either a single file or all files in a directory from *.md to *.html
⍝ Needs a directory "Markdown2HTML" as a sibling of the user command lives holding the
⍝ workspace and the CSS files needed for the conversion.\\
⍝ The main purpose of this user command is to be called by a `Make` process when Markdown
⍝ files need to be converted into HTML files for the final package, but of course it can
⍝ also be used to "manually" convert a particular Markdown file into an HTML file.\\
⍝ Kai Jaeger\\
⍝ Version 1.1.0 from 2018-09-09\\

    ∇ r←List;⎕IO;⎕ML
      ⎕IO←⎕ML←1
      r←⎕NS¨1⍴⊂''
      r.Name←⊂'Markdown2HTML'
      r[1].Desc←⊂'Takes the name of a Markdown file or a directory holding *.md files and converts it/them to HTML5 files.'
      r.Group←⊂'APLTree'
     ⍝ Parsing rules:
      r[1].Parse←'1s -parameterfile= -createParameterFile -version'
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
      CheckForUpdatedMarkAPL rf(home,'Markdown2HTML')
      :If 2⊃Args.SwD[({0(819⌶)⊣⍵}¨Args.SwD[;1])⍳⊂'createparameterfile';]
          r←CreateParameterFile rf
      :ElseIf 2⊃Args.SwD[({0(819⌶)⊣⍵}¨Args.SwD[;1])⍳⊂'version';]
          r←ReportVersionNumbers rf
      :Else
          r←Process rf Args
      :EndIf
    ∇

    ∇ r←CreateParameterFile rf
      r←rf.Markdown2HTML.CreateParameterFile''
    ∇

    ∇ r←Process(rf Args);filenames;path;cssParms;css;msg;arg;success;buff;target;parms;errMsgs;parameterFile
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
      :If (,0)≡,parameterFile←Args.Switch'parameterfile'
          parms←rf.MarkAPL.CreateParms
      :Else
          parms←GetParmsFromParameterFile parameterFile
      :EndIf
      :If parms.cssURL≡⎕NULL
          parms.cssURL←rf.FilesAndDirs.PWD
      :EndIf
      (success msg errMsgs)←parms rf.Markdown2HTML.ProcessFiles filenames path target
      r←success,[1.5]msg
    ∇

    ∇ parms←GetParmsFromParameterFile filename;buff;bool
⍝ `filename` is the name of a parameter file, typically created by calling MarkAPL.CreateParms
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
      :Select 0(819⌶)Cmd
      :Case 'markdown2htmlparameterfile'
          r,←⊂'Creates a parameter file; this is a JSON version of what MarkAPL.CreateParms creates.'
          r,←⊂'The parameter file is created in the TEMP folder.'
          r,←⊂'The filename is returned as result.'
      :Case 'markdown2html'
          :Select ⊃level
          :Case 0
              r,←⊂'This user command converts one to many markdown files into'
              r,←⊂'HTML files with the help of the MarkAPL class.'
              r,←⊂''
              r,←⊂'If defaults do not suit ones need one can create a parameter'
              r,←⊂'file with'
              r,←⊂'      ]filename←Markdown2Html -createParameterFile'
              r,←⊂'and then change the defaults in that file.'
              r,←⊂'Note that when -createParameterFile is specified everything else is ignored.'
              r,←⊂'That filename can then be passed with -parameterfile=<filename> as in:'
              r,←⊂'      ]Markdown2Html <anyMarkdownFile> -parameterFile=<filename>'
              r,←⊂'For details enter'
              :If 17>⊃(//)⎕VFI{⍵/⍨2>+\'.'=⍵}(1+⎕IO)⊃'#'⎕WG'APLVersion'
                  r,←⊂'      ]??Markdown2Html'
              :Else
                  r,←⊂'      ]Markdown2Html -??'
              :EndIf
              r,←⊂'With the flag -version you can get a report on the version number of:'
              r,←⊂'* the Markdown2HTML script'
              r,←⊂'* the MarkAPL class used for the conversion.'
              r,←⊂'Note that -version, -parameterfile and -createparameterfile are mutually exclusive.'
          :CaseList 1 2
              r,←⊂'Takes one of:'
              r,←⊂' * The name of a Markdown file;'
              r,←⊂'   That file is then converted into an HTML file.'
              r,←⊂' * The name of a folder holding Markdown files;'
              r,←⊂'   All Markdown files in that folder are converted into HTML files.'
              r,←⊂''
              r,←⊂'If the filename has no extension then ".md" is assumed.'
              r,←⊂'For a folder you can, say, specify C:\MyFiles\*.markdown.'
              r,←⊂'Note that you can only specify one extension.'
              r,←⊂''
              r,←⊂'The output filename is the same as the input filename except that'
              r,←⊂'the extension will become ".html".'
              r,←⊂''
              r,←⊂'The User Command returns a matrix with two columns:'
              r,←⊂'* [;1] = Boolean (1=success)'
              r,←⊂'* [;2] = Output filename'
              r,←⊂''
              r,←⊂'In case the folder specified (or hosting the specfied Markdown file)'
              r,←⊂'contains a file .Markdown2HTML the contents is honoured. This can be'
              r,←⊂'used to specify a folder the HTML files to be created will go into'
              r,←⊂'(rather than becoming a sibling of the Markdown file).'
              r,←⊂'For example, if the file .Markdown2HTML contains this:'
              r,←⊂'..\'
              r,←⊂'then the HTML file(s) will be saved in the parent directory.'
          :EndSelect
      :EndSelect
    ∇

    ∇ {r}←CheckForUpdatedMarkAPL(targetNS path);buff
      r←⍬
      :If targetNS.FilesAndDirs.IsFile path,'\Markapl.script'
          buff←targetNS.APLTreeUtils.ReadUtf8File path,'\Markapl.script'
          r←targetNS.⎕FIX buff
          'Could not fix MarkAPL.script'⎕SIGNAL 11/⍨0∊⍴r
          'Could not fix MarkAPL.script'⎕SIGNAL 11/⍨' '≠1↑0⍴⍕r
      :EndIf
     ⍝Done
    ∇

    ∇ r←ReportVersionNumbers rf
      r←0 2⍴''
      r⍪←'Markdown2HTML:'(2⊃rf.Markdown2HTML.Version)
      r⍪←'MarkAPL'(2⊃rf.MarkAPL.Version)
    ∇

:EndNamespace