% code eval for read text syntax.
cmap=containers.Map;
cmap('Measure')=1;
cmap('FGen')=2;
cmap('Laser')=3;
cmap('RF')=4;

code=fileread('testEvalGateSyntaxCode.m');
gate=TTLGenerator;

EvalGateSyntax(gate,code,cmap);