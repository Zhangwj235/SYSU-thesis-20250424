\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sysuthesis}[2024/01/31 sysu thesis template]

% 报错和警告
\newcommand\sysu@error[1]{%
	\ClassError{sysuthesis}{#1}{}%
}
\newcommand\sysu@warning[1]{%
	\ClassWarning{sysuthesis}{#1}%
}

% 检查 LaTeX kernel 版本
\providecommand\IfFormatAtLeastTF{\@ifl@t@r\fmtversion}
\IfFormatAtLeastTF{2022-06-01}{}{%
	\sysu@error{%
		TeX Live 2022 or later version is required to compile this document%
	}
}

% 检查编译引擎，要求使用 XeLaTeX 或者 LuaLaTeX。
\RequirePackage{iftex}
\ifxetex
\else
	\ifluatex
	\else
		\sysu@error{XeLaTeX or LuaLaTeX is required to compile this document}
	\fi
\fi

\RequirePackage{kvdefinekeys}
\RequirePackage{kvsetkeys}
\RequirePackage{kvoptions}

\SetupKeyvalOptions{
	family=sysu,
	prefix=sysu@,
	setkeys=\kvsetkeys}
\let\sysu@setup@hook\@empty
\newcommand\sysusetup[1]{%
	\let\sysu@setup@hook\@empty
	\kvsetkeys{sysu}{#1}%
	\sysu@setup@hook
}
\newcommand\sysu@define@key[1]{%
	\kvsetkeys{sysu@key}{#1}%
}
\kv@set@family@handler{sysu@key}{%
	\@namedef{sysu@#1@@name}{#1}%
	\def\sysu@@default{}%
	\def\sysu@@choices{}%
	\kv@define@key{sysu@value}{name}{%
		\@namedef{sysu@#1@@name}{##1}%
	}%
	\@namedef{sysu@#1@@check}{}%
	\@namedef{sysu@#1@@code}{}%
	\kv@define@key{sysu@value}{choices}{%
		\def\sysu@@choices{##1}%
		\@namedef{sysu@#1@@reset}{}%
		\@namedef{sysu@#1@@check}{%
			\@ifundefined{%
				ifsysu@\@nameuse{sysu@#1@@name}@\@nameuse{sysu@\@nameuse{sysu@#1@@name}}%
			}{%
				\sysu@error{Invalid value "#1 = \@nameuse{sysu@\@nameuse{sysu@#1@@name}}"}%
			}%
			\@nameuse{sysu@#1@@reset}%
			\@nameuse{sysu@\@nameuse{sysu@#1@@name}@\@nameuse{sysu@\@nameuse{sysu@#1@@name}}true}%
		}%
	}%
	\kv@define@key{sysu@value}{default}{%
		\def\sysu@@default{##1}%
	}%
	\kvsetkeys{sysu@value}{#2}%
	\@namedef{sysu@\@nameuse{sysu@#1@@name}}{}%
	\kv@set@family@handler{sysu@choice}{%
		\ifx\sysu@@default\@empty
			\def\sysu@@default{##1}%
		\fi
		\expandafter\newif\csname ifsysu@\@nameuse{sysu@#1@@name}@##1\endcsname
		\expandafter\g@addto@macro\csname sysu@#1@@reset\endcsname{%
			\@nameuse{sysu@\@nameuse{sysu@#1@@name}@##1false}%
		}%
	}%
	\kvsetkeys@expandafter{sysu@choice}{\sysu@@choices}%
	\expandafter\let\csname sysu@\@nameuse{sysu@#1@@name}\endcsname\sysu@@default
	\expandafter\ifx\csname sysu@\@nameuse{sysu@#1@@name}\endcsname\@empty\else
		\@nameuse{sysu@#1@@check}%
	\fi
	\kv@define@key{sysu}{#1}{%
		\@namedef{sysu@\@nameuse{sysu@#1@@name}}{##1}%
		\@nameuse{sysu@#1@@check}%
		\@nameuse{sysu@#1@@code}%
	}%
}

\sysu@define@key{
	print = {
			choices = {
					oneside,
					twoside,
				},
			default = oneside,
		},
	cover-title = {
			name = cover@title,
			choices = {
					oneline,
					twoline,
				},
			default = oneline,
		},
	number = {
			choices = {
					chinese,
					arabic,
				},
			default = arabic,
		},
	color = {
			default = sysugreen,
		},
}

\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{ctexbook}}
\ProcessKeyvalOptions*

\ifsysu@print@twoside
	\PassOptionsToClass{openright,twoside}{book}
\else
	\PassOptionsToClass{openany,oneside}{book}
\fi

% XeTeX 下使用伪粗体
\ifXeTeX
	\PassOptionsToPackage{AutoFakeBold=2.5}{xeCJK}
\fi

\LoadClass[ 
     %fontset=adobe2, % 可手动下载adobe，并选用此项 
     fontset=fandol,    % texlive自带，可移植字体库，只有常用的6763个汉字 
     %fontset=ubuntu, %这个可行但是华文宋体
     %fontset=mac, 
     %fontset=windows, % 在windows系统下使用这一行的命令以显示生僻字 
     a4paper, 
     %openright, 
     openany, 
     zihao=-4 
 ]{ctexbook} 

\RequirePackage{xparse}
\RequirePackage{unicode-math}
\RequirePackage{amsmath}
\RequirePackage{fontspec}
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{titletoc}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{enumitem}
\RequirePackage{float}
\RequirePackage{caption}
\RequirePackage[perpage,bottom]{footmisc}
\RequirePackage{notoccite}
% \RequirePackage{sysuvisual}

\AddToHook{begindocument/before}{%
	\@ifpackageloaded{biblatex}{}{%
		\RequirePackage{natbib}
	}
	% URL 的字体设为保持原样。
	\urlstyle{same}
}

% 对冲突的宏包报错。
\newcommand\sysu@package@conflict[2]{%
	\AddToHook{package/#1/after}{%
		\AddToHook{package/#2/before}{%
			\sysu@error{The "#2" package is incompatible with "#1"}%
		}
	}
}

\sysu@package@conflict{biblatex}{bibunits}
\sysu@package@conflict{biblatex}{chapterbib}
\sysu@package@conflict{biblatex}{cite}
\sysu@package@conflict{biblatex}{multibib}
\sysu@package@conflict{biblatex}{natbib}

\sysu@package@conflict{bibunits}{biblatex}
\sysu@package@conflict{bibunits}{chapterbib}
\sysu@package@conflict{bibunits}{multibib}

\sysu@package@conflict{unicode-math}{amscd}
\sysu@package@conflict{unicode-math}{amsfonts}
\sysu@package@conflict{unicode-math}{amssymb}
\sysu@package@conflict{unicode-math}{bbm}
\sysu@package@conflict{unicode-math}{bm}
\sysu@package@conflict{unicode-math}{eucal}
\sysu@package@conflict{unicode-math}{eufrak}
\sysu@package@conflict{unicode-math}{mathrsfs}
\sysu@package@conflict{unicode-math}{newtxmath}
\sysu@package@conflict{unicode-math}{upgreek}

\sysu@package@conflict{natbib}{biblatex}
\sysu@package@conflict{natbib}{cite}

\sysu@package@conflict{newtxmath}{amsfonts}
\sysu@package@conflict{newtxmath}{amssymb}
\sysu@package@conflict{newtxmath}{unicode-math}
\sysu@package@conflict{newtxmath}{upgreek}

\def\contentsname{目录}%
\def\listfigurename{插图目录}%
\def\listtablename{表格目录}%
\def\bibname{参考文献}%
\def\appendixname{附录}%
\def\sysu@acknowledgements@name{致谢}%

% 注意重定义 \normalsize 应在 unicode-math 的 \setmathfont 前。

% \renewcommand\normalsize{%
%     \@setfontsize\normalsize{12bp}{18bp}%
%     \abovedisplayskip 12bp \@plus3bp \@minus7bp%
%     \abovedisplayshortskip \z@ \@plus3bp%
%     \belowdisplayshortskip 6.5bp \@plus3.5bp \@minus3bp%
%     \belowdisplayskip \abovedisplayskip
%     \let\@listi\@listI}%
% \normalsize
% \ifx\MakeRobust\@undefined \else
%     \MakeRobust\normalsize
% \fi
% \renewcommand\small{%
%     \@setfontsize\small{10.5bp}{15.75bp}%
%     \abovedisplayskip 10.5bp \@plus3bp \@minus6bp%
%     \abovedisplayshortskip \z@ \@plus3bp%
%     \belowdisplayshortskip 6.5bp \@plus3.5bp \@minus3bp%
%     \belowdisplayskip \abovedisplayskip
% }%
% \renewcommand\footnotesize{%
%     \@setfontsize\footnotesize{9bp}{13.5bp}%
%     \abovedisplayskip 9bp \@plus2bp \@minus5bp%
%     \abovedisplayshortskip \z@ \@plus3bp%
%     \belowdisplayshortskip 6bp \@plus3bp \@minus3bp%
%     \belowdisplayskip \abovedisplayskip
% }%
% \renewcommand\scriptsize{\@setfontsize\scriptsize{7.5bp}{11.25bp}}%
% \renewcommand\tiny{\@setfontsize\tiny{6.5bp}{9.75bp}}%
% \renewcommand\large{\@setfontsize\large{15bp}{22.5bp}}%
% \renewcommand\Large{\@setfontsize\Large{18bp}{27bp}}%
% \renewcommand\LARGE{\@setfontsize\LARGE{22bp}{33bp}}%
% \renewcommand\huge{\@setfontsize\huge{24bp}{36bp}}%
% \renewcommand\Huge{\@setfontsize\Huge{26bp}{39bp}}%

% 设置行距的倍数为 1.5。
\linespread{1.5}\selectfont

% 带圈数字使用中文字体。
\ifXeTeX
	\xeCJKDeclareCharClass{CJK}{%
		"24EA,        % ⓪
		"2460->"2473, % ①->⑳
		"3251->"32BF, % ㉑->㊿
		"24FF,        % ⓿
		"2776->"277F, % ❶->❿
		"24EB->"24F4  % ⓫->⓴
	}
\fi

\ifLuaTeX
	\ltjdefcharrange{6}{%
		"24EA, "2460-"2473, "3251-"32BF,
		"24FF, "2776-"277F, "24EB-"24F4}
\fi

% 纸张：A4；
% 页面设置：上边距 25 mm，下边距 20 mm，左右边距均为 30 mm。

\geometry{
	paper      = a4paper,
	vmargin    = {2.5cm, 2.0cm},
	hmargin    = 3.0cm,
	headheight = 0.75cm,
	headsep    = 0.5cm,
	footskip   = 0.75cm,
}

% 页脚与页眉设置
\pagestyle{fancy}
\let\sectionmark\@gobble

\fancypagestyle{plain}{%
	\fancyhf{}%
	% 本科生要求除封面、扉页外，每面上部加页眉，
	% 用 5 号字标注“中山大学本科毕业论文”，居中；
	% 从目录页开始在每面底部居中用五号宋体（10.5 bp）连续编页码。
	\def\sysu@hf@font{\rmfamily\zihao{5}}
	\fancyhead[C]{\sysu@hf@font 中山大学本科毕业论文}%
	\fancyfoot[C]{\sysu@hf@font\thepage}%
	\let\@mkboth\@gobbletwo
	\let\chaptermark\@gobble
	\let\sectionmark\@gobble
}
\pagestyle{plain}

% 空白页不加页眉和页码。
\def\cleardoublepage{%
	\clearpage
	\ifsysu@print@twoside
		\ifodd\c@page\else
			\hbox{}%
			\thispagestyle{empty}%
			\newpage
			\if@twocolumn
				\hbox{}%
				\newpage
			\fi
		\fi
	\fi
}

%
% 本科生要求从“中文摘要”开始页码用大写罗马数字，
\renewcommand\frontmatter{%
	\cleardoublepage
	\@mainmatterfalse
	\pagenumbering{Roman}%
	\pagestyle{plain}%
}

\renewcommand\mainmatter{%
	\cleardoublepage
	\pagenumbering{arabic}%
	\pagestyle{plain}%
	\@mainmattertrue
}

\g@addto@macro\appendix{%
	\ctexset{
		chapter = {
		  aftername = \hskip 0.75em,
		  numberformat = \normalfont\bfseries,
		 },
		section = {
		  name = {附\space},
		  number = \thesection,
		  numberformat = \normalfont\bfseries,
		 },
		subsection = {
				name = {附\space},
				number = \thesubsection,
				numberformat = \normalfont\bfseries,
			},
		subsubsection = {
				name = {附\space},
				number = \thesubsubsection,
				numberformat = \normalfont\bfseries,
			},
	}%
}

% 定义用户接口：
\sysu@define@key{
	title = {
			default = {论文题目},
		},
	title* = {
			default = {Title},
			name    = title@en,
		},
	author = {
			default = {作者姓名},
		},
	author* = {
			default = {Author Name},
			name    = author@en,
		},
	department = {
			default = {学院},
		},
	department* = {
			default = {Department},
			name    = department*en,
		},
	speciality = {
			default = {专业},
		},
	speciality* = {
			default = {Speciality},
			name    = speciality@en,
		},
	supervisor = {
			default = {导师姓名},
		},
	supervisor* = {
			default = {Supervisor Name},
			name    = supervisor@en,
		},
	date = {
			default = {\the\year-\two@digits{\month}-\two@digits{\day}},
		},
	student-id = {
			name = student@id,
		},
	keywords,
	keywords* = {
			name    = keywords@en,
		},
	cover-title-firstline = {
			name    = cover@title@firstline,
			default = {标题第一行},
		},
	cover-title-firstline* = {
			name    = cover@title@firstline@en,
			default = {Title first line},
		},
	cover-title-secondline = {
			name    = cover@title@secondline,
			default = {标题第二行},
		},
	cover-title-secondline* = {
			name    = cover@title@secondline@en,
			default = {Title last line}
		},
}

% 导师一栏可能有多个姓名，所以用 supervisor 进行收集，
\newcommand\sysu@clist@count[1]{%
	\csname clist_count:N\endcsname{#1}%
}
\newcommand\sysu@clist@use[2]{%
	\csname clist_use:Nn\endcsname{#1}{#2}%
}
\newcommand\sysu@supervisor@names{%
	\sysu@clist@use{\sysu@supervisor}{\quad}
}
\newcounter{sysu@count}
\newcommand\sysu@supervisor@en@line{%
	\setcounter{sysu@count}{\sysu@clist@count{\sysu@supervisor@en}}%
	\ifnum\c@sysu@count>1\relax
		Supervisors%
	\else
		Supervisor%
	\fi
	\space\sysu@clist@use{\sysu@supervisor@en}{, }%
}

% 输出日期的给定格式。
% 其中格式 format 接受三个参数分别对应年、月、日，
% date 是 ISO 格式的日期 (yyyy-mm-dd)。
\newcommand\sysu@format@date[2]{%
	\edef\sysu@@date{#2}%
	\def\sysu@@process@date##1-##2-##3\@nil{%
		#1{##1}{##2}{##3}%
	}%
	\expandafter\sysu@@process@date\sysu@@date\@nil
}
\newcommand\sysu@date@format@zh@small[3]{\number#1 年 \number#2 月 \number#3 日}
\newcommand\sysu@date@format@zh@small@underline[3]{%
	\underline{\hskip 1ex\number#1\hskip 1ex} 年
	\underline{\hskip 1ex\number#2\hskip 1ex} 月
	\underline{\hskip 1ex\number#3\hskip 1ex} 日}
\newcommand\sysu@date@format@zh@big[3]{\zhdigits{#1} 年 \zhnumber{#2} 月 \zhnumber{#3} 日}
\newcommand\sysu@date@month[1]{%
	\ifcase\number#1\or
		January\or February\or March\or April\or May\or June\or
		July\or August\or September\or October\or November\or December%
	\fi
}
\newcommand\sysu@date@format@en[3]{\sysu@date@month{#2} \number#3, #1}
\newcommand\sysu@date@zh@small{\sysu@format@date{\sysu@date@format@zh@small}{\sysu@date}}
\newcommand\sysu@date@zh@small@underline{\sysu@format@date{\sysu@date@format@zh@small@underline}{\sysu@date}}
\newcommand\sysu@date@zh@big{\sysu@format@date{\sysu@date@format@zh@big}{\sysu@date}}
\newcommand\sysu@date@en{\sysu@format@date{\sysu@date@format@en}{\sysu@date}}

% 定义一些常量。
\newcommand\sysu@thesis@name{本科生毕业论文（设计）}

% 添加 PDF 书签
\newcommand\sysu@pdfbookmark{\@gobble}

% 重定义 titlepage 环境，不修改页码。
\renewenvironment{titlepage}{%
	\cleardoublepage
	\if@twocolumn
		\@restonecoltrue\onecolumn
	\else
		\@restonecolfalse\newpage
	\fi
	\thispagestyle{empty}%
}{%
	\if@restonecol\twocolumn \else \newpage \fi
}

% 设置封面字体
\ExplSyntaxOn
\sys_if_platform_windows:TF{%
	\newCJKfontfamily\titlefont{STZhongsong}
}{
	\newcommand{\titlefont}{\songti}
}
\ExplSyntaxOff

% 本科生的封面
\newcommand\sysu@makecover{%
	\begin{titlepage}%
		\sysu@pdfbookmark{封面}%
		\centering
		% \sysubadge{3cm}{\sysu@color}
		\includegraphics[width=3cm]{figures/sysu-badge.pdf}

		\begingroup%
		\titlefont\bfseries\fontsize{36bp}{36bp}\selectfont
		\textcolor{\sysu@color}{\sysu@thesis@name}\par
		\endgroup

		% 做分割线
		% \begin{tikzpicture}[remember picture, overlay]
		%     \coordinate(here);
		%     \draw[line width=3.75pt, color=\sysu@color]
		%     (current page.west |- here) -- +(\paperwidth,0);
		%     \draw[line width=1.25pt, color=\sysu@color]
		%     (current page.west |- here)++(0pt,-5pt) -- +(\paperwidth,0);
		% \end{tikzpicture}
		% \vspace*{\stretch{1}}
		\makebox[\linewidth]{
			\color{\sysu@color}
			\rule{\paperwidth}{3.75pt}
		} \par
		\vskip 2.5pt
		\makebox[\linewidth]{
			\color{\sysu@color}
			\rule[\baselineskip]{\paperwidth}{1.25pt}
		} \par
		\vspace*{\stretch{0.5}}

		% 论文标题 黑体二号居中
		\begingroup%
		\heiti\fontsize{22bp}{33bp}\selectfont
		\ifsysu@cover@title@oneline
			\begin{tabular}{p{3em}@{}p{18em}}
				题目： & \underline{\makebox[16em]{\sysu@title}}
			\end{tabular}
		\else
			\begin{tabular}{p{3em}@{}p{18em}}
				题目： & \underline{\makebox[16em]{\sysu@cover@title@firstline}}  \\
				    & \underline{\makebox[16em]{\sysu@cover@title@secondline}}
			\end{tabular}
		\fi\par
		\endgroup
		\vspace*{\stretch{1}}

		\begingroup%
		\fontsize{15bp}{22.5bp}\heiti\selectfont
		\renewcommand\arraystretch{1.5}
		\begin{tabular}{p{4em}p{16em}}
			\makebox[4em][s]{姓\hss 名} & \underline{\makebox[14em]{\sysu@author}}           \\
			\makebox[4em][s]{学\hss 号} & \underline{\makebox[14em]{\sysu@student@id}}       \\
			\makebox[4em][s]{院\hss 系} & \underline{\makebox[14em]{\sysu@department}}       \\
			\makebox[4em][s]{专\hss 业} & \underline{\makebox[14em]{\sysu@speciality}}       \\
			\makebox[4em][s]{指导教师}    & \underline{\makebox[14em]{\sysu@supervisor@names}}
		\end{tabular}
		\par\endgroup
		\vskip 18bp

		% 利用 tabularray 生成，需引入宏包 tabularray
		% \begingroup%
		% \heiti\fontsize{22bp}{33bp}\selectfont
		% \ifsysu@cover@title@oneline
		%     题目：\underline{\makebox[12cm]{\sysu@title}}
		% \else
		%     \begin{tblr}{column{2} = {12cm, c}, rows = {1.8cm, f}, rowsep = 0pt, colsep = 4pt}
		%         题目： & \sysu@cover@title@firstline  \\
		%         \cline[0.5pt, solid]{2}
		%             & \sysu@cover@title@secondline \\
		%         \cline[0.5pt, solid]{2}
		%     \end{tblr}
		% \fi\par
		% \endgroup
		% \vspace*{\stretch{1}}

		% \begingroup%
		% \fontsize{15bp}{22.5bp}\heiti\selectfont
		% \begin{tblr}{column{2} = {8.5cm, c}, rows = {1.5cm, f}, rowsep = 0pt}
		%     \makebox[4\ccwd][s]{姓\hss 名} & \sysu@author           \\
		%     \cline[0.5pt, solid]{2}
		%     \makebox[4\ccwd][s]{学\hss 号} & \sysu@student@id       \\
		%     \cline[0.5pt, solid]{2}
		%     \makebox[4\ccwd][s]{院\hss 系} & \sysu@department       \\
		%     \cline[0.5pt, solid]{2}
		%     \makebox[4\ccwd][s]{专\hss 业} & \sysu@speciality       \\
		%     \cline[0.5pt, solid]{2}
		%     \makebox[4\ccwd][s]{指导教师}    & \sysu@supervisor@names \\
		%     \cline[0.5pt, solid]{2}
		% \end{tblr}
		% \par\endgroup
		% \vskip 18bp

		\begingroup
		\fontsize{12bp}{18bp}\heiti\selectfont
		\sysu@date@zh@small@underline\par
		\endgroup
		\vspace*{\stretch{1}}
	\end{titlepage}%
}

\newcommand\sysu@maketitlepage{
	\begin{titlepage}
		\sysu@pdfbookmark{扉页}
		\centering
		\vspace*{\stretch{1}}

		%论文题目 黑体二号居中
		\fontsize{22bp}{27.5bp}\heiti\selectfont
		\ifsysu@cover@title@oneline
			\sysu@title
		\else
			\sysu@cover@title@firstline \par \sysu@cover@title@secondline
		\fi
		\vspace*{\stretch{2}}

		\ifsysu@cover@title@oneline
			\sysu@title@en
		\else
			\sysu@cover@title@firstline@en \par \sysu@cover@title@secondline@en
		\fi
		\vspace*{\stretch{2}}

		\begingroup
		\fontsize{16bp}{24bp}\heiti\selectfont
		\renewcommand\arraystretch{1.5}
		\begin{tabular}{p{4em}p{16em}}
			\makebox[4em][s]{姓\hss 名} & \underline{\makebox[14em]{\sysu@author}}           \\
			\makebox[4em][s]{学\hss 号} & \underline{\makebox[14em]{\sysu@student@id}}       \\
			\makebox[4em][s]{院\hss 系} & \underline{\makebox[14em]{\sysu@department}}       \\
			\makebox[4em][s]{专\hss 业} & \underline{\makebox[14em]{\sysu@speciality}}       \\
			\makebox[4em][s]{指导教师}    & \underline{\makebox[14em]{\sysu@supervisor@names}}
		\end{tabular}\par
		\endgroup
		\vspace*{\stretch{1.5}}

		\fontsize{14bp}{21bp}\selectfont
		\sysu@date@zh@small@underline\par
		\vspace*{\stretch{1.5}}
	\end{titlepage}
}

\newcommand\sysu@originality{%
	本人郑重声明：所呈交的毕业论文（设计），是本人在导师的指导下，独立进行研究工作所取得的成果。
	除文中已经注明引用的内容外，本论文（设计）不包含任何其他个人或集体已经发表或撰写过的作品成果。
	对本论文（设计）的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。
	本论文（设计）的知识产权归属于培养单位。本人完全意识到本声明的法律结果由本人承担。}

\newcommand\sysu@makecopyrightpage{%
	\begin{titlepage}%
		\sysu@pdfbookmark{学术诚信声明}%
		\null
		\vspace*{\baselineskip}%
		\begingroup%
		\centering\heiti\zihao{3}%
		学术诚信声明\par%
		\endgroup%
		\vspace*{\baselineskip}%

		\sysu@originality\par
		\vspace*{2\baselineskip}%

		\begin{flushright}
			\renewcommand\arraystretch{1.5}
			\begin{tabular}{cc}
				\makebox[4em][s]{作者签名}：    &                                        \\
				\makebox[4em][s]{日\hss 期}： & \hskip 6ex 年 \hskip 6ex 月 \hskip 6ex 日
			\end{tabular}
		\end{flushright}
	\end{titlepage}%
}

% 生成中文封面。
\renewcommand\maketitle{%
	\newgeometry{
		hmargin = 0cm,
		vmargin = {2.5cm, 2cm},
	}
	\pagenumbering{Alph}
	\pagestyle{empty}%
	\sysu@makecover
	\sysu@maketitlepage
	\restoregeometry%
	\sysu@makecopyrightpage
	\cleardoublepage%
}

% 脚注需要使用带圈的数字
\newcommand\sysu@textcircled[1]{%
	\ifnum\value{#1}<21\relax
		{\symbol{\numexpr\value{#1} + "245F\relax}}%
	\else
		\sysu@error{Cannot display more than 20 footnotes}%
	\fi
}


% 用 ctex 的接口设置全部章节标题格式。

\setcounter{secnumdepth}{4}
\setcounter{tocdepth}{1}

\AtBeginDocument{%
	\ifsysu@number@arabic%
		\ctexset{
			chapter = {
			  numbering = true,
			  name = {},
			  number = \thechapter,
			  format = \centering\heiti\zihao{3},
			  numberformat = \normalfont\bfseries,
			  aftername = \hskip 0.75em,
			  beforeskip = \baselineskip,
			  afterskip = \baselineskip,
			  fixskip = true,
			 },
			section = {
			  numbering = true,
			  name = {},
			  number = \thesection,
			  format = \heiti\zihao{4},
			  numberformat = \normalfont\bfseries,
			  aftername = \hskip 0.75em,
			  beforeskip = \baselineskip,
			  afterskip = \baselineskip,
			  fixskip = true,
			 },
			subsection = {
					numbering = true,
					name = {},
					number = \thesubsection,
					format = \bfseries\songti\zihao{-4},
					numberformat = \normalfont\bfseries,
					aftername = \hskip 0.75em,
					indent = 2\ccwd,
					beforeskip = \baselineskip,
					afterskip = \baselineskip,
					fixskip = true,
				},
			subsubsection = {
					numbering = true,
					name = {},
					number = \thesubsubsection,
					format = \bfseries\songti\zihao{-4},
					numberformat = \normalfont\bfseries,
					aftername = \hskip 0.75em,
					indent = 2\ccwd,
					beforeskip = \baselineskip,
					afterskip = \baselineskip,
					fixskip = true,
				},
			paragraph = {
					numbering = false,
					name = {},
					format = \bfseries\songti\zihao{-4},
					indent = 2\ccwd,
					beforeskip = \baselineskip,
					afterskip = \baselineskip,
					fixskip = true,
				},
		}%
	\else%
		\ctexset{
			chapter = {
			  numbering = true,
			  name = {},
			  number = \chinese{chapter},
			  format = \centering\heiti\zihao{3},
			  aftername = {、\ignorespaces},
			  beforeskip = \baselineskip,
			  afterskip = \baselineskip,
			  fixskip = true,
			 },
			section = {
			  numbering = true,
			  name = {（,）},
			  number = \chinese{section},
			  format = \heiti\zihao{4},
			  aftername = \hskip 0.5em,
			  beforeskip = \baselineskip,
			  afterskip = \baselineskip,
			  fixskip = true,
			 },
			subsection = {
					numbering = true,
					name = {},
					number = \arabic{subsection},
					format = \bfseries\songti\zihao{-4},
					numberformat = \normalfont\bfseries,
					aftername = \hskip 0.75em,
					indent = 2\ccwd,
					beforeskip = \baselineskip,
					afterskip = \baselineskip,
					fixskip = true,
				},
			subsubsection = {
					numbering = true,
					name = {（,）},
					number = \arabic{subsubsection},
					format = \bfseries\songti\zihao{-4},
					numberformat = \normalfont\bfseries,
					aftername = \hskip 0.75em,
					indent = 2\ccwd,
					beforeskip = \baselineskip,
					afterskip = \baselineskip,
					fixskip = true,
				},
			paragraph = {
					numbering = false,
					name = {},
					format = \bfseries\songti\zihao{-4},
					indent = 2\ccwd,
					beforeskip = \baselineskip,
					afterskip = \baselineskip,
					fixskip = true,
				},
		}%
	\fi%
}

% 将不带编号的 chapter 加入书签
\NewDocumentCommand\sysu@chapter{o m}{%
	\if@openright\cleardoublepage\else\clearpage\fi
	\IfValueTF{#1}{%
		\sysu@pdfbookmark{#1}%
		\chaptermark{#1}%
	}{%
		\sysu@pdfbookmark{#2}%
		\chaptermark{#2}%
	}%
	\chapter*{#2}
}

\newcommand\sysu@keywords@text{%
	\sysu@clist@use{\sysu@keywords}{，}%
}
\newcommand\sysu@keywords@en@text{%
	\sysu@clist@use{\sysu@keywords@en}{, }%
}

\newenvironment{abstract}{%
	\sysu@chapter[中文摘要]{摘要}%
}{
	\par\null\par\noindent\hangindent=4\ccwd\relax
	\textbf{关键词}：\sysu@keywords@text\par
}

% 英文摘要环境
\newenvironment{abstract*}{%
	\sysu@chapter[英文摘要]{\textbf{ABSTRACT}}%
}{
	\par\null\par\noindent\hangindent=5.3em\relax
	\textbf{Keywords}: \sysu@keywords@en@text\par
	\cleardoublepage
}

% 目录
\renewcommand\tableofcontents{%
	\sysu@chapter{\contentsname}%
	\@starttoc{toc}%
}

% 定义目录线
\newcommand\sysu@leaders{\titlerule*[8pt]{.}}

% 定义页码宽度
\contentsmargin{3ex}

% 本科生的目录使用小四宋体（同正文字体）
\titlecontents{chapter}
[3ex]{\addvspace{8bp}\normalsize}
{\contentslabel{3ex}}{\hskip-3ex}
{\sysu@leaders\contentspage}

\titlecontents{section}
[7.5ex]{\normalsize}
{\contentslabel{4.5ex}}{\hskip-4.5ex}
{\sysu@leaders\contentspage}

\titlecontents{subsection}
[13.5ex]{\normalsize}
{\contentslabel{6ex}}{\hskip-6ex}
{\sysu@leaders\contentspage}

\titlecontents{subsubsection}
[21ex]{\normalsize}
{\contentslabel{7.5ex}}{\hskip-7.5ex}
{\sysu@leaders\contentspage}

\g@addto@macro\appendix{%
	\titlecontents{chapter}
	[8ex]{\addvspace{8bp}\normalsize}
	{\contentslabel{8ex}}{\hskip-8ex}
	{\sysu@leaders\contentspage}

	\titlecontents{section}
	[15ex]{\normalsize}
	{\contentslabel{7ex}}{\hskip-7ex}
	{\sysu@leaders\contentspage}

	\titlecontents{subsection}
	[23.5ex]{\normalsize}
	{\contentslabel{8.5ex}}{\hskip-8.5ex}
	{\sysu@leaders\contentspage}

	\titlecontents{subsubsection}
	[33.5ex]{\normalsize}
	{\contentslabel{10ex}}{\hskip-10ex}
	{\sysu@leaders\contentspage}
}

\renewcommand\chapter{%
  \ifsysu@print@twoside\cleardoublepage\else\clearpage\fi
  \global\@topnum\z@
  \@afterindenttrue
  \secdef\@chapter\@schapter
 }

% 处理表格目录以及插图目录
\renewcommand\listoffigures{%
	\cleardoublepage
	\sysu@chapter{\listfigurename}%
	\@starttoc{lof}%
}

\renewcommand\listoftables{%
	\cleardoublepage
	\sysu@chapter{\listtablename}%
	\@starttoc{lot}%
}

% 段间距 0 磅。
\setlength{\parskip}{\z@}

% 首段缩进。
\ctexset{autoindent=true}

% 脚注用带圈的数字：
\renewcommand\thefootnote{\sysu@textcircled{footnote}}

% 注文缩进两字。在脚注内容中，计数器以非上标样式输出：
\def\@makefnmark@nosuperscript{\hbox{\normalfont\@thefnmark}}

\renewcommand\@makefntext[1]{%
	\parindent 2\ccwd\relax
	\noindent
	\hb@xt@2\ccwd{\hss\@makefnmark@nosuperscript} #1}

% 调整列表中各项之间过大的间距。
\setlength\partopsep{\z@}
\newcommand\sysu@nolistsep{%
	\parsep 0\p@ \@plus.2\p@
	\topsep 0\p@ \@plus.2\p@
	\itemsep0\p@ \@plus.2\p@
}
\def\@listi{\leftmargin\leftmargini
	\sysu@nolistsep}
\let\@listI\@listi
\@listi
\def\@listii {\leftmargin\leftmarginii
	\labelwidth\leftmarginii
	\advance\labelwidth-\labelsep
	\sysu@nolistsep}
\def\@listiii{\leftmargin\leftmarginiii
	\labelwidth\leftmarginiii
	\advance\labelwidth-\labelsep
	\sysu@nolistsep}

% 按 https://texfaq.org/FAQ-floats 的建议对浮动体放宽要求。
\renewcommand{\topfraction}{.85}
\renewcommand{\bottomfraction}{.7}
\renewcommand{\textfraction}{.15}
\renewcommand{\floatpagefraction}{.66}
\renewcommand{\dbltopfraction}{.66}
\renewcommand{\dblfloatpagefraction}{.66}
\setcounter{topnumber}{9}
\setcounter{bottomnumber}{9}
\setcounter{totalnumber}{20}
\setcounter{dbltopnumber}{9}

% 图号、图题置于图的下方，宋体 10.5 磅居中。
\DeclareCaptionLabelSeparator{zhspace}{\hspace{\ccwd}}
\captionsetup{
	format         = hang,
	font           = small,
	labelsep       = zhspace,
	skip           = 4pt,
	figureposition = bottom,
	tableposition  = top,
}

% 参考文献
\PassOptionsToPackage{compress}{natbib}

\AddToHook{package/natbib/after}{%
	% 为了将参考文献加入目录和 pdf 书签，重新定义 natbib 的 \bibsection
	\renewcommand\bibsection{%
		\@mainmatterfalse
		\chapter{\bibname}%
	}
	% 参考文献内容 宋体 5 号
	\renewcommand\bibfont{%
		\zihao{5}
	}
}

% biblatex 宏包的配置
\AddToHook{package/biblatex/after}{%
	\defbibheading{bibliography}[\bibname]{%
		\@mainmatterfalse
		\chapter{\bibname}%
	}
	\renewcommand\bibfont{%
		\zihao{5}
	}
}

% 附录

% 定义致谢环境
\newenvironment{acknowledgements}{%
	\@mainmatterfalse
	\chapter{\sysu@acknowledgements@name}%
}{}

% 其他宏包的设置

\AddToHook{package/hyperref/after}{%
	\hypersetup{
		% bookmarksnumbered  = true,
		CJKbookmarks       = true,
		linktoc            = all,
		unicode            = true,
	}
	% 设置 hyperlink 颜色
	\hypersetup{
		colorlinks = true,
		linkcolor  = black,
		filecolor  = \sysu@color,
		citecolor  = \sysu@color,
		urlcolor   = \sysu@color
	}
	% 填写 PDF 元信息。
	\AtBeginDocument{%
		\hypersetup{
			pdftitle    = \sysu@title,
			pdfauthor   = \sysu@author,
			pdfkeywords = \sysu@keywords,
		}%
	}
	% 添加 PDF 书签
	\newcounter{sysu@bookmarknumber}
	\renewcommand\sysu@pdfbookmark[1]{%
		\phantomsection
		\stepcounter{sysu@bookmarknumber}%
		\pdfbookmark[0]{#1}{sysuchapter.\thesysu@bookmarknumber}%
	}
	%
	% 在 PDF 字符串中去掉换行，以减少 hyperref 的警告信息。
	\pdfstringdefDisableCommands{%
		\let\\\relax
		\let\quad\relax
		\let\qquad\relax
		\let\hspace\@gobble
	}
	% 设置中文的 \autoref。
	\def\equationautorefname~#1\null{公式~(#1)\null}
	\def\footnoteautorefname{脚注}
	\def\itemautorefname~#1\null{第~#1~项\null}
	\def\figureautorefname{图}
	\def\tableautorefname{表}
	\def\partautorefname~#1\null{第~#1~部分\null}
	\def\appendixautorefname{附录}
	\def\chapterautorefname~#1\null{第~#1~章\null}
	\def\sectionautorefname~#1\null{第~#1~节\null}
	\def\subsectionautorefname~#1\null{第~#1~小节\null}
	\def\subsubsectionautorefname~#1\null{第~#1~小小节\null}
	\def\paragraphautorefname~#1\null{第~#1~段\null}
	\def\suptaragraphautorefname~#1\null{第~#1~小段\null}
	\def\HyRef@autopageref#1{\hyperref[{#1}]{第~\pageref*{#1} 页}}
	\def\assertionautorefname{\sysu@assertion@name}
	\def\assumptionautorefname{\sysu@assumption@name}
	\def\axiomautorefname{\sysu@axiom@name}
	\def\corollaryautorefname{\sysu@corollary@name}
	\def\definitionautorefname{\sysu@definition@name}
	\def\exampleautorefname{\sysu@example@name}
	\def\lemmaautorefname{\sysu@lemma@name}
	\def\propositionautorefname{\sysu@proposition@name}
	\def\theoremautorefname{\sysu@theorem@name}
}

% 定义校徽颜色
% 推迟定义颜色以避免调用 xcolor 时的警告
\AtBeginDocument{%
	\definecolor{sysugreen}{cmyk}{1, 0, 1, 0.6}
	\definecolor{sysured}{cmyk}{0.3, 1, 1, 0.5}
}

\AddToHook{package/amsthm/after}{%
	\newtheoremstyle{sysuplain}
	{6pt}{6pt}
	{}{2\ccwd}
	{\bfseries}{}
	{\ccwd}{}
	\theoremstyle{sysuplain}
	% 定义新的定理
	\newcommand\sysu@assertion@name{断言}
	\newcommand\sysu@assumption@name{假设}
	\newcommand\sysu@axiom@name{公理}
	\newcommand\sysu@corollary@name{推论}
	\newcommand\sysu@definition@name{定义}
	\newcommand\sysu@example@name{例}
	\newcommand\sysu@lemma@name{引理}
	\newcommand\sysu@proof@name{证明}
	\newcommand\sysu@proposition@name{命题}
	\newcommand\sysu@remark@name{注}
	\newcommand\sysu@theorem@name{定理}

	\newtheorem{theorem}{\sysu@theorem@name}[chapter]

	\newaliascnt{assertion}{theorem}
	\newtheorem{assertion}[assertion]{\sysu@assertion@name}
	\aliascntresetthe{assertion}

	\newaliascnt{axiom}{theorem}
	\newtheorem{axiom}[axiom]{\sysu@axiom@name}
	\aliascntresetthe{axiom}

	\newaliascnt{corollary}{theorem}
	\newtheorem{corollary}[corollary]{\sysu@corollary@name}
	\aliascntresetthe{corollary}

	\newaliascnt{lemma}{theorem}
	\newtheorem{lemma}[lemma]{\sysu@lemma@name}
	\aliascntresetthe{lemma}

	\newaliascnt{proposition}{theorem}
	\newtheorem{proposition}[proposition]{\sysu@proposition@name}
	\aliascntresetthe{proposition}

	\newtheorem{assumption}{\sysu@assumption@name}[chapter]
	\newtheorem{definition}{\sysu@definition@name}[chapter]
	\newtheorem{example}{\sysu@example@name}[chapter]
	\newtheorem*{remark}{\sysu@remark@name}

	% 重定义 proof 环境
	% \renewcommand\qedsymbol{ $\mdlgwhtsquare$ }
	\renewenvironment{proof}[1][\sysu@proof@name]{\par
		\pushQED{\qed}%
		\normalfont \topsep6\p@\@plus6\p@\relax
		\trivlist
		\item\relax\hskip2\ccwd
		\textbf{#1}
		\hskip\ccwd\ignorespaces
	}{%
		\popQED\endtrivlist\@endpefalse
	}
}

% 按章节编号。
\PassOptionsToPackage{algochapter}{algorithm2e}

\AddToHook{package/algorithm2e/after}{%
	\SetAlgorithmName{算法}{算法}{算法清单}
	% 设置算法环境的格式。
	\SetAlCapSkip{6pt}
	\SetAlCapFnt{\small}
	\SetAlCapNameFnt{\small}
	\SetAlgoCaptionSeparator{\hspace*{\ccwd}}
	% 设置算法清单的格式
	\renewcommand\listofalgocfs{%
		\cleardoublepage
		\sysu@chapter{\listalgorithmcfname}%
		\@starttoc{loa}%
	}
	\titlecontents{algocf}
	[2.3em]{\normalsize}
	{\contentslabel{2.3em}}{}
	{\sysu@leaders\contentspage}
	\contentsuse{algocf}{loa}
}
