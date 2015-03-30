(* ::Package:: *)

(* ::Title:: *)
(*QuantumUtils for Mathematica*)
(*Predicates Package*)


(* ::Subsection::Closed:: *)
(*Copyright and License Information*)


(* ::Text:: *)
(*This package is part of QuantumUtils for Mathematica.*)
(**)
(*Copyright (c) 2015 and later, Christopher J. Wood, Christopher E. Granade, Ian N. Hincks*)
(**)
(*Redistribution and use in source and binary forms, with or withoutmodification, are permitted provided that the following conditions are met:*)
(*1. Redistributions of source code must retain the above copyright notice, this  list of conditions and the following disclaimer.*)
(*2. Redistributions in binary form must reproduce the above copyright notice,  this list of conditions and the following disclaimer in the documentation  and/or other materials provided with the distribution.*)
(*3. Neither the name of quantum-utils-mathematica nor the names of its  contributors may be used to endorse or promote products derived from  this software without specific prior written permission.*)
(**)
(*THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THEIMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE AREDISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLEFOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIALDAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS ORSERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVERCAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USEOF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.*)


(* ::Subsection::Closed:: *)
(*Preamble*)


BeginPackage["Predicates`"];


(* ::Text:: *)
(*The following packages are needed, but their contexts should not be loaded globally.*)


Needs["UnitTesting`"];
Needs["QUDevTools`"];


$Usages = LoadUsages[FileNameJoin[{$QUDocumentationPath, "api-doc", "Predicates.nb"}]];


(* ::Section::Closed:: *)
(*Usage Declarations*)


(* ::Subsection::Closed:: *)
(*Fuzzy Logic*)


Unprotect[PossiblyTrueQ,PossiblyFalseQ,PossiblyNonzeroQ];


AssignUsage[PossiblyTrueQ,$Usages];
AssignUsage[PossiblyFalseQ,$Usages];
AssignUsage[PossiblyNonzeroQ,$Usages];


(* ::Subsection::Closed:: *)
(*Numbers and Lists*)


Unprotect[AnyQ,AnyMatchQ,AnyElementQ,AllQ,AllMatchQ,AllElementQ,AnyNonzeroQ,AnyPossiblyNonzeroQ];


AssignUsage[AnyQ,$Usages];
AssignUsage[AnyMatchQ,$Usages];
AssignUsage[AnyElementQ,$Usages];


AssignUsage[AllQ,$Usages];
AssignUsage[AllMatchQ,$Usages];
AssignUsage[AllElementQ,$Usages];


AssignUsage[AnyNonzeroQ,$Usages];
AssignUsage[AnyPossiblyNonzeroQ,$Usages];


(* ::Subsection::Closed:: *)
(*Symbolic Expressions*)


Unprotect[SymbolQ,ScalarQ,CoefficientSymbolQ,CoefficientQ];


AssignUsage[SymbolQ,$Usages];
AssignUsage[ScalarQ,$Usages];
AssignUsage[CoefficientSymbolQ,$Usages];
AssignUsage[CoefficientQ,$Usages];


(* ::Subsection::Closed:: *)
(*Matrices and Vectors*)


Unprotect[NonzeroDimQ,DiagonalMatrixQ,PureStateQ,ColumnVectorQ,RowVectorQ,GeneralVectorQ];


AssignUsage[NonzeroDimQ,$Usages];
AssignUsage[DiagonalMatrixQ,$Usages];
AssignUsage[PureStateQ,$Usages];
AssignUsage[ColumnVectorQ,$Usages];
AssignUsage[RowVectorQ,$Usages];
AssignUsage[GeneralVectorQ,$Usages];


(* ::Section::Closed:: *)
(*Implementation*)


Begin["`Private`"];


(* ::Subsection::Closed:: *)
(*Fuzzy Logic*)


PossiblyTrueQ[expr_]:=\[Not]TrueQ[\[Not]expr]


PossiblyFalseQ[expr_]:=\[Not]TrueQ[expr]


PossiblyNonzeroQ[expr_]:=PossiblyTrueQ[expr!=0]


(* ::Subsection::Closed:: *)
(*Numbers and Lists*)


AnyQ[cond_, L_] := Fold[Or, False, cond /@ L]
AllQ[cond_, L_] := Fold[And, True, cond /@ L]


AnyMatchQ[cond_, L_] := AnyQ[MatchQ[#,cond]&,L]
AllMatchQ[cond_, L_] := AllQ[MatchQ[#,cond]&,L]


AnyElementQ[cond_,L_]:=AnyQ[cond,Flatten[L]]
AllElementQ[cond_, L_] := AllQ[cond,Flatten[L]]


AnyNonzeroQ[L_]:=AnyElementQ[#!=0&,L]


AnyPossiblyNonzeroQ[expr_]:=AnyElementQ[PossiblyNonzeroQ,expr]


(* ::Subsection::Closed:: *)
(*Symbolic Expressions*)


SymbolQ[a_]:=
	And[
		SameQ[Head[a],Symbol],
		SameQ[DownValues[a],{}]
	];


ScalarQ[a_]:=Or[NumericQ[a],SymbolQ[a],StringQ[a]]


CoefficientSymbolQ[a_]:=
	And[SymbolQ[a],
		SameQ[DownValues[a],{}],
		SameQ[#,{}]||SameQ[#,{Temporary}]||MemberQ[#,NumericFunction]&[Attributes@a]
	]


CoefficientQ[expr_]:=
	Or[ScalarQ[expr],
	With[{head=Head[expr]},
		And[
			MatchQ[expr,_[__]],
			Or[StringQ[head],CoefficientSymbolQ[head]],
			AllQ[ScalarQ[#]||CoefficientQ[#]&, List@@expr]
		]
	]]


(* ::Subsection::Closed:: *)
(*Matrices and Vectors*)


NonzeroDimQ:=\[Not]MemberQ[Dimensions[#],0]&


DiagonalMatrixQ[A_?MatrixQ]:=
	If[SquareMatrixQ[A],
		Module[{n=Length[A],dlist},
			dlist=List/@Plus[Range[0,n-1]*(n+1),1];
			Total[Abs[Delete[Flatten[A],dlist]]]===0],
	False
	];


PureStateQ[A_]:=TrueQ[Tr[ConjugateTranspose[A].A]==1];


ColumnVectorQ[v_]:=MatchQ[Dimensions[v],{_,1}];


RowVectorQ[v_]:=MatchQ[Dimensions[v],{1,_}];


GeneralVectorQ[v_]:=Or[VectorQ[v],ColumnVectorQ[v]];


(* ::Subsection::Closed:: *)
(*End Private*)


End[];


(* ::Section::Closed:: *)
(*Backward Compatibility*)


(* ::Subsection:: *)
(*Version Check*)


Begin["`Private`"];

(* TODO: check Polyfill works! *)

SetAttributes[Polyfill, HoldRest];

Polyfill[goodVersion_, expr_] := If[$VersionNumber < goodVersion,
	ReleaseHold[HoldComplete[expr]]
];


End[];


(* ::Subsection:: *)
(*Usage Strings*)


Predicates`Private`Polyfill[10,
	NormalMatrixQ::usage="Returns True if the object is a normal matrix";
	SquareMatrixQ::usage="Returns True if and only if the argument is a square matrix";
	PositiveSemidefiniteMatrixQ::usage="Returns True if and only if the chopped eigenvalues of the argument are non-negative.";
];


(* ::Subsection:: *)
(*Implementation*)


Begin["`Private`"];


Predicates`Private`Polyfill[10,
	NormalMatrixQ[M_]:=M.ConjugateTranspose[M]===ConjugateTranspose[M].M;
	SquareMatrixQ[M_]:=TrueQ[MatrixQ[M]&&Dimensions[M][[1]]==Dimensions[M][[2]]];
	PositiveSemidefiniteMatrixQ[M_?SquareMatrixQ]:=With[{evals=Eigenvalues[M]},Not[MemberQ[NonNegative[evals],False]]&&Not[Norm[evals]==0]];
];


End[];


(* ::Section::Closed:: *)
(*Unit Testing*)


Begin["`Private`"];


(* ::Subsection::Closed:: *)
(*Fuzzy Logic*)


TestCase["Predicates:PossiblyTrueQ", 
	And[
		Module[{maybe},PossiblyTrueQ[maybe]],
		PossiblyTrueQ[True],
		Not@PossiblyTrueQ[0 == 2]
	]];


TestCase["Predicates:PossiblyFalseQ", 
	And[
		Module[{maybe}, PossiblyFalseQ[maybe]],
		Not@PossiblyFalseQ[True],
		PossiblyFalseQ[0 == 2]
	]]


TestCase["Predicates:PossiblyNonzeroQ", 
	And[
		Module[{maybe}, PossiblyNonzeroQ[maybe]],
		Not@PossiblyNonzeroQ[0]
	]]


(* ::Subsection::Closed:: *)
(*Numbers and Lists*)


TestCase["Predicates:AnyQ", AnyQ[# >= 2 &, {0, 1, 5}]];


TestCase["Predicates:AllElementQ", AllElementQ[# >= 2 &, {3, {{{{4}}}}, 5}]];


TestCase["Predicates:AnyMatchQ", AnyMatchQ[_Integer,{0, 1.2, 5.5}]];


TestCase["Predicates:AllQ", AnyQ[# >= 2 &, {2, 4, 5}]];


TestCase["Predicates:AnyElementQ", AnyElementQ[# >= 2 &, {{{{4}, 0}}, 1}]]


TestCase["Predicates:AllMatchQ", AllMatchQ[_Integer,{2, 4, 5}]];


TestCase["Predicates:AnyNonzeroQ", AnyNonzeroQ[{0, 1, 5}]];


TestCase["Predicates:AnyPossiblyNonzeroQ", Module[{maybe}, AnyPossiblyNonzeroQ[{0, maybe, 0}]]]


(* ::Subsection::Closed:: *)
(*Symbolic Expressions*)


TestCase["Predicates:SymbolQ", 
	And[
		Not@SymbolQ[12],
		Module[{arg},SymbolQ[arg]],
		Module[{f},f[x_]:=x; Not@SymbolQ[f]],
		With[{x=10},Not@SymbolQ[x]]
	]];


TestCase["Predicates:CoefficientQ",
	Module[{f,g,x,y},
	And[
		CoefficientQ[Sin[3*x]],
		CoefficientQ[g[x,y]],
		CoefficientQ[f[g[x]]],
		CoefficientQ[x],
		CoefficientQ[Sin["x"]],
		SetAttributes[g,Protected];Not@CoefficientQ[g[x]],
		Not@CoefficientQ[KroneckerProduct[x,y]],
		Not@CoefficientQ[Dot[1,2]]
	]]];


(* ::Subsection::Closed:: *)
(*Matrices and Lists*)


TestCase["Predicates:NonzeroDimQ",
	And[
		Not@NonzeroDimQ[{{{},{}}}],
		NonzeroDimQ[{1,2,3}]
	]];


TestCase["Predicates:DiagonalMatrixQ", 
	And[
		DiagonalMatrixQ@DiagonalMatrix[{1,2,3}],
		Not@DiagonalMatrixQ[{{1,2},{3,4}}]
	]];


TestCase["Predicates:PureStateQ", 
	And[
		PureStateQ[{{1,1},{1,1}}/2],
		Not@PureStateQ[{{1,0},{0,3}}/4]
	]];


TestCase["Predicates:ColumnVectorQ",
	And[
		ColumnVectorQ[{{0},{1}}],
		Not@ColumnVectorQ[{0,0,1}],
		Not@ColumnVectorQ[{{0,1}}]
	]];


TestCase["Predicates:RowVectorQ",
	And[
		Not@RowVectorQ[{{0},{1}}],
		Not@RowVectorQ[{0,0,1}],
		RowVectorQ[{{0,1}}]
	]];


TestCase["Predicates:GeneralVectorQ",
	And[
		GeneralVectorQ[{{0},{1}}],
		GeneralVectorQ[{0,0,1}],
		Not@GeneralVectorQ[{{0,1}}]
	]];


(* ::Subsection::Closed:: *)
(*End Private*)


End[];


(* ::Section::Closed:: *)
(*End Package*)


Protect[PossiblyTrueQ,PossiblyFalseQ,PossiblyNonzeroQ];
Protect[AnyQ,AnyMatchQ,AnyElementQ,AllQ,AllMatchQ,AllElementQ,AnyNonzeroQ,AnyPossiblyNonzeroQ];
Protect[SymbolQ,CoefficientQ];
Protect[NonzeroDimQ,DiagonalMatrixQ,PureStateQ,ColumnVectorQ,RowVectorQ,GeneralVectorQ];


EndPackage[];