\ProvidesClass{salary}[2022/09/11 salary doc settings]
\NeedsTeXFormat{LaTeX2e}
\LoadClass[11pt]{article}

% For page number calculations
\RequirePackage{ifthen}

% To handle key=value options in class definition
\RequirePackage{kvoptions}
\SetupKeyvalOptions{%
    prefix=salary@
}

% Default currency option is "dollar"
\DeclareStringOption[sek]{currency}[sek]
\ProcessKeyvalOptions*

\RequirePackage{eurosym}

% Customizing lists
\RequirePackage{enumitem}

\ifthenelse{\equal{\salary@currency}{dollar}}{\newcommand{\currencysym}{\$}}{}
\ifthenelse{\equal{\salary@currency}{euro}}{\newcommand{\currencysym}{\euro}}{}
\ifthenelse{\equal{\salary@currency}{pound}}{\newcommand{\currencysym}{\textsterling}}{}
\ifthenelse{\equal{\salary@currency}{sek}}{\newcommand{\currencysym}{kr}}{}

% Set the standard geometry
\RequirePackage[hmargin=.75in,vmargin=1in]{geometry}

% For links and metadata
\RequirePackage[hidelinks]{hyperref}

% For adjusting letter spacing
\RequirePackage{soul}

% For "At*" hooks
\RequirePackage{etoolbox}

% For adjusting footer
\RequirePackage{fancyhdr}

% For tables
\RequirePackage{tabularx}

% Dates
\RequirePackage[en-US]{datetime2}

% Localization
\RequirePackage[swedish]{babel}
\RequirePackage[utf8]{inputenc}
\RequirePackage{fontspec}

\defaultfontfeatures{Ligatures=TeX}

% Phone numbers formatting
\RequirePackage{phonenumbers}

% For invoice math
\RequirePackage{fp}
\RequirePackage{tikz}

% Formatting numbers
\RequirePackage{siunitx}
% Using thinspace for group separator instead of , or . to avoid locale specific settings and confusion.
\sisetup{round-integer-to-decimal, group-separator={\thinspace}}
% Map babel setting to sisetup locale setting. This changes the decimal separator.
\addto\extrasenglish{\sisetup{locale = US}}
\addto\extrasfrench{\sisetup{locale = FR}}
\addto\extrasswedish{\sisetup{locale = FR}}

\defaultfontfeatures{
    Ligatures = TeX,
    Path      = ./Fonts/ }

\IfFileExists{./Fonts/OpenSans-Regular.ttf}{
    \setmainfont[ BoldFont = OpenSans-Bold, ItalicFont = OpenSans-Italic ]{OpenSans-Regular}
    \setsansfont[ BoldFont = OpenSans-Bold, ItalicFont = OpenSans-Italic ]{OpenSans-Regular}
}{}

%%%%% Commands %%%%%

\newcommand{\advancedate}[2]{%
    \DTMsetdate{#1}%
    \DTMaddmonths{#2}%
    \DTMdisplaydate
}

\newcommand*{\setmetadata}[1]{
    \hypersetup{
        bookmarksopen  = false,
        bookmarksdepth = 2,% to show sections and subsections
        pdfauthor      = {#1},
        pdftitle       = {L\"onebesked},
        pdfsubject     = {L\"onebesked},
        pdfkeywords    = {l\"onebesked, #1}
    }
}

\newcommand*{\twocolumnlayout}[2]{
    \enspace #1 \hfill #2 \enspace
}

\sodef\invoiceSpacing{}{.15em}{.4em}{.4em}
\newcommand*{\makeheader}[1]{
    \begin{minipage}[t]{.6\linewidth} {\headerStyle #1} \end{minipage}
    \hfill
    \begin{tabular}[t]{@{} c @{}}
    {\headerStyle L\"onebesked} \\
    {\today} \\
    \end{tabular}

    \addvspace{8ex}
}

\newcommand*{\dateDay}[1]{%
    \DTMsavedate{mydate}{#1}
    \DTMusedate{mydate}
}

\newcommand*{\dateNoDay}[1]{%
    \DTMsavedate{mydate}{#1}
    \DTMlangsetup{showdayofmonth=false}
    \DTMusedate{mydate}
    \DTMlangsetup{showdayofmonth=true}
}

\newenvironment*{infoSection}[1]{\tabular[t]{@{}l@{}}\titleStyle{#1:}\\}{\endtabular}
\newenvironment*{footerSection}[1]{\tabular[t]{@{}l@{}}\footerTitleStyle{#1:}\\}{\endtabular}
\newcommand{\sectionItem}[1]{#1 \\}

\newcommand{\emaillink}[1]{%
    \href{mailto:#1}{#1}%
}

\newcommand*{\itemizationRowStyle}[0]{\small}
\newcommand*{\itemizationHeaderStyle}[0]{\normalsize}
\newcounter{colskipcount}

\newenvironment{salaryItemization}{%
    \setcounter{colskipcount}{2}
    \tabularx{\textwidth}{c X r}
    \hline
    \noalign{\smallskip}
    {\itemizationHeaderStyle Datum} &
        {\itemizationHeaderStyle Beskrivning} &
        {\itemizationHeaderStyle Belopp(SEK)} \\
    \hline
    \noalign{\bigskip}
    }{\endtabularx}

\newcommand{\lineitem}[3]{  %{Date}{Amount}{Description}
        {\itemizationRowStyle \dateNoDay{#1}} &
        {\itemizationRowStyle #3} &
        {\itemizationRowStyle \calcamount{#2}}
    \\
%\noalign{\bigskip}
}

\newenvironment{contactIconItemization}{\tabular[t]{@{}c@{}@{}l@{}}}{\endtabular}
\newcommand{\contactIconItem}[2]{#1 & \hspace{8pt}\small#2\\}

\gdef\SalaryTotal{0}

\newcommand{\subtotal}{%
    \SalaryTotal%
}

\newcommand{\vattotal}{%
    \FPmul\p{\vatPercent}{0.01}%
    \FPmul\result{\p}{\subtotal}%
    \formatcurrency{\result}%
}

\newcommand{\total}{%
    \FPmul\p{\vatPercent}{0.01}%
    \FPsub\pp{1}{\p}%
    \FPmul\result{\pp}{\subtotal}%
    \formatcurrency{\result}%
}

\newcommand*{\calcamount}[1]{%
    \FPmul\t{#1}{1}%
    \formatcurrency{#1}%
    % TabularX runs the body multiple times https://tex.stackexchange.com/a/227155
    % Since SalaryTotal is a global variable it'd count those runs as well.
    % Check if it's the final run. This seems hacky, but keeping it until a better soultion if found.
    \ifx\@tempdima\hfuzz%
    \else%
    \FPadd\gt{\SalaryTotal}{\t}%
    \global\let\SalaryTotal\gt%
    \fi%
}

\newcommand{\beginsummary}{
    \noalign{\bigskip}
    \hline
    \noalign{\medskip}
}

\newcommand*{\summaryline}[2]{
    \multicolumn{\thecolskipcount}{r}{\itemizationHeaderStyle #1} & #2 \\
}

\newcommand*{\formatcurrency}[1]{%
    \num[group-separator={\thinspace}, group-minimum-digits=3, round-mode=places, round-precision=2]{#1}%
}

% Implementation by Werner (http://tex.stackexchange.com/a/176815/35707)
\newcommand*{\dectofrac}[1]{\begingroup%
\pgfkeys{/pgf/number format/frac}% Format as fraction
\let\frac\sfrac% Let \frac act like \sfrac
\pgfmathprintnumber{#1}\endgroup}

% Debugging
\newcommand{\showbb}[1]{{\color{red!50}\leavevmode\rlap{\fbox{\phantom{#1}}}}#1}

%%%%% Styles %%%%%
\def\headerStyle{\Huge}
\def\titleStyle{\large\bf}
\def\footerTitleStyle{\small\bf}

% Add page numbers
\fancypagestyle{plain}{
    \renewcommand{\headrulewidth}{0pt}
    \renewcommand{\footrulewidth}{0pt}
    \fancyhf{}}
% page numbers in footer if more than 1 page
% Copied from moderncv
\AtEndPreamble{%
    \AtBeginDocument{%
        \@ifundefined{r@lastpage}{}{%
            \ifthenelse{\pageref{lastpage}>1}{%
                \newlength{\pagenumberwidth}%
                \settowidth{\pagenumberwidth}{\thepage/\pageref{lastpage}}%
                \fancypagestyle{plain}{%
                    \fancyfoot[r]{\parbox[b]{\pagenumberwidth}{\thepage/\pageref{lastpage}}}%
                }%
                \pagestyle{plain}%
            }{}%
        }%
        \AtEndDocument{\label{lastpage}}%
    }%
}
\pagestyle{plain}

% Disable paragraph indent
\setlength{\parindent}{0pt}
