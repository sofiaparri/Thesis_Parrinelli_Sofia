function [tpl, str] = subst(tpl,handle)
%TEMPLATE/SUBST Substitute a replacement field by its value
%  STR = SUBST(TPL,HANDLE) substitute all the known fields of variable HANDLE
%  in the template TPL.

%  Copyright (C) 2003 Guillaume Flandin <Guillaume@artefact.tk>
%  $Revision: 1.1 $Date: 2008-09-03 08:36:22 $

tpl = loadtpl(tpl,handle);

str = get(tpl,'var',handle);
for i=1:length(tpl.varkeys)
	str = strrep(str, strcat('{',tpl.varkeys{i},'}'), tpl.varvals{i});
end
