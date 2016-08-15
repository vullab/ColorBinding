#!/usr/bin/env python
"""

Build call-back mechanism for f2py2e.

Copyright 2000 Pearu Peterson all rights reserved,
Pearu Peterson <pearu@ioc.ee>
Permission to use, modify, and distribute this software is given under the
terms of the NumPy License.

NO WARRANTY IS EXPRESSED OR IMPLIED.  USE AT YOUR OWN RISK.
$Date: 2005/07/20 11:27:58 $
Pearu Peterson
"""

__version__ = "$Revision: 1.53 $"[10:-1]

import __version__
f2py_version = __version__.version


import pprint
import sys,string,time,types,copy
errmess=sys.stderr.write
outmess=sys.stdout.write
show=pprint.pprint

from auxfuncs import *
import capi_maps
#from capi_maps import *
import cfuncs

################## Rules for callback function ##############

cb_routine_rules={
    'cbtypedefs':'typedef #rctype#(*#name#_typedef)(#optargs_td##args_td##strarglens_td##noargs#);',
    'body':"""
#begintitle#
PyObject *#name#_capi = NULL;/*was Py_None*/
PyTupleObject *#name#_args_capi = NULL;
int #name#_nofargs = 0;
jmp_buf #name#_jmpbuf;
/*typedef #rctype#(*#name#_typedef)(#optargs_td##args_td##strarglens_td##noargs#);*/
#static# #rctype# #callbackname# (#optargs##args##strarglens##noargs#) {
\tPyTupleObject *capi_arglist = #name#_args_capi;
\tPyObject *capi_return = NULL;
\tPyObject *capi_tmp = NULL;
\tint capi_j,capi_i = 0;
\tint capi_longjmp_ok = 1;
#decl#
#ifdef F2PY_REPORT_ATEXIT
f2py_cb_start_clock();
#endif
\tCFUNCSMESS(\"cb:Call-back function #name# (maxnofargs=#maxnofargs#(-#nofoptargs#))\\n\");
\tCFUNCSMESSPY(\"cb:#name#_capi=\",#name#_capi);
\tif (#name#_capi==NULL) {
\t\tcapi_longjmp_ok = 0;
\t\t#name#_capi = PyObject_GetAttrString(#modulename#_module,\"#argname#\");
\t}
\tif (#name#_capi==NULL) {
\t\tPyErr_SetString(#modulename#_error,\"cb: Callback #argname# not defined (as an argument or module #modulename# attribute).\\n\");
\t\tgoto capi_fail;
\t}
\tif (PyCObject_Check(#name#_capi)) {
\t#name#_typedef #name#_cptr;
\t#name#_cptr = PyCObject_AsVoidPtr(#name#_capi);
\t#returncptr#(*#name#_cptr)(#optargs_nm##args_nm#);
\t#return#
\t}
\tif (capi_arglist==NULL) {
\t\tcapi_longjmp_ok = 0;
\t\tcapi_tmp = PyObject_GetAttrString(#modulename#_module,\"#argname#_extra_args\");
\t\tif (capi_tmp) {
\t\t\tcapi_arglist = (PyTupleObject *)PySequence_Tuple(capi_tmp);
\t\t\tif (capi_arglist==NULL) {
\t\t\t\tPyErr_SetString(#modulename#_error,\"Failed to convert #modulename#.#argname#_extra_args to tuple.\\n\");
\t\t\t\tgoto capi_fail;
\t\t\t}
\t\t} else {
\t\t\tPyErr_Clear();
\t\t\tcapi_arglist = (PyTupleObject *)Py_BuildValue(\"()\");
\t\t}
\t}
\tif (capi_arglist == NULL) {
\t\tPyErr_SetString(#modulename#_error,\"Callback #argname# argument list is not set.\\n\");
\t\tgoto capi_fail;
\t}
#setdims#
#pyobjfrom#
\tCFUNCSMESSPY(\"cb:capi_arglist=\",capi_arglist);
\tCFUNCSMESS(\"cb:Call-back calling Python function #argname#.\\n\");
#ifdef F2PY_REPORT_ATEXIT
f2py_cb_start_call_clock();
#endif
\tcapi_return = PyObject_CallObject(#name#_capi,(PyObject *)capi_arglist);
#ifdef F2PY_REPORT_ATEXIT
f2py_cb_stop_call_clock();
#endif
\tCFUNCSMESSPY(\"cb:capi_return=\",capi_return);
\tif (capi_return == NULL) {
\t\tfprintf(stderr,\"capi_return is NULL\\n\");
\t\tgoto capi_fail;
\t}
\tif (capi_return == Py_None) {
\t\tPy_DECREF(capi_return);
\t\tcapi_return = Py_BuildValue(\"()\");
\t}
\telse if (!PyTuple_Check(capi_return)) {
\t\tcapi_return = Py_BuildValue(\"(N)\",capi_return);
\t}
\tcapi_j = PyTuple_Size(capi_return);
\tcapi_i = 0;
#frompyobj#
\tCFUNCSMESS(\"cb:#name#:successful\\n\");
\tPy_DECREF(capi_return);
#ifdef F2PY_REPORT_ATEXIT
f2py_cb_stop_clock();
#endif
\tgoto capi_return_pt;
capi_fail:
\tfprintf(stderr,\"Call-back #name# failed.\\n\");
\tPy_XDECREF(capi_return);
\tif (capi_longjmp_ok)
\t\tlongjmp(#name#_jmpbuf,-1);
capi_return_pt:
\t;
#return#
}
#endtitle#
""",
    'need':['setjmp.h','CFUNCSMESS'],
    'maxnofargs':'#maxnofargs#',
    'nofoptargs':'#nofoptargs#',
    'docstr':"""\
\tdef #argname#(#docsignature#): return #docreturn#\\n\\
#docstrsigns#""",
    'latexdocstr':"""
{{}\\verb@def #argname#(#latexdocsignature#): return #docreturn#@{}}
#routnote#

#latexdocstrsigns#""",
    'docstrshort':'def #argname#(#docsignature#): return #docreturn#'
    }
cb_rout_rules=[
    {# Init
    'separatorsfor':{'decl':'\n',
                     'args':',','optargs':'','pyobjfrom':'\n','freemem':'\n',
                     'args_td':',','optargs_td':'',
                     'args_nm':',','optargs_nm':'',
                     'frompyobj':'\n','setdims':'\n',
                     'docstrsigns':'\\n"\n"',
                     'latexdocstrsigns':'\n',
                     'latexdocstrreq':'\n','latexdocstropt':'\n',
                     'latexdocstrout':'\n','latexdocstrcbs':'\n',
                     },
    'decl':'/*decl*/','pyobjfrom':'/*pyobjfrom*/','frompyobj':'/*frompyobj*/',
    'args':[],'optargs':'','return':'','strarglens':'','freemem':'/*freemem*/',
    'args_td':[],'optargs_td':'','strarglens_td':'',
    'args_nm':[],'optargs_nm':'','strarglens_nm':'',
    'noargs':'',
    'setdims':'/*setdims*/',
    'docstrsigns':'','latexdocstrsigns':'',
    'docstrreq':'\tRequired arguments:',
    'docstropt':'\tOptional arguments:',
    'docstrout':'\tReturn objects:',
    'docstrcbs':'\tCall-back functions:',
    'docreturn':'','docsign':'','docsignopt':'',
    'latexdocstrreq':'\\noindent Required arguments:',
    'latexdocstropt':'\\noindent Optional arguments:',
    'latexdocstrout':'\\noindent Return objects:',
    'latexdocstrcbs':'\\noindent Call-back functions:',
    'routnote':{hasnote:'--- #note#',l_not(hasnote):''},
    },{ # Function
    'decl':'\t#ctype# return_value;',
    'frompyobj':[{debugcapi:'\tCFUNCSMESS("cb:Getting return_value->");'},
                 '\tif (capi_j>capi_i)\n\t\tGETSCALARFROMPYTUPLE(capi_return,capi_i++,&return_value,#ctype#,"#ctype#_from_pyobj failed in converting return_value of call-back function #name# to C #ctype#\\n");',
                 {debugcapi:'\tfprintf(stderr,"#showvalueformat#.\\n",return_value);'}
                 ],
    'need':['#ctype#_from_pyobj',{debugcapi:'CFUNCSMESS'},'GETSCALARFROMPYTUPLE'],
    'return':'\treturn return_value;',
    '_check':l_and(isfunction,l_not(isstringfunction),l_not(iscomplexfunction))
    },
    {# String function
    'pyobjfrom':{debugcapi:'\tfprintf(stderr,"debug-capi:cb:#name#:%d:\\n",return_value_len);'},
    'args':'#ctype# return_value,int return_value_len',
    'args_nm':'return_value,&return_value_len',
    'args_td':'#ctype# ,int',
    'frompyobj':[{debugcapi:'\tCFUNCSMESS("cb:Getting return_value->\\"");'},
                 """\tif (capi_j>capi_i)
\t\tGETSTRFROMPYTUPLE(capi_return,capi_i++,return_value,return_value_len);""",
                 {debugcapi:'\tfprintf(stderr,"#showvalueformat#\\".\\n",return_value);'}
                 ],
    'need':['#ctype#_from_pyobj',{debugcapi:'CFUNCSMESS'},
            'string.h','GETSTRFROMPYTUPLE'],
    'return':'return;',
    '_check':isstringfunction
    },
    {# Complex function
    'optargs':"""
#ifndef F2PY_CB_RETURNCOMPLEX
#ctype# *return_value
#endif
""",
    'optargs_nm':"""
#ifndef F2PY_CB_RETURNCOMPLEX
return_value
#endif
""",
    'optargs_td':"""
#ifndef F2PY_CB_RETURNCOMPLEX
#ctype# *
#endif
""",
    'decl':"""
#ifdef F2PY_CB_RETURNCOMPLEX
\t#ctype# return_value;
#endif
""",
    'frompyobj':[{debugcapi:'\tCFUNCSMESS("cb:Getting return_value->");'},
                     """\
\tif (capi_j>capi_i)
#ifdef F2PY_CB_RETURNCOMPLEX
\t\tGETSCALARFROMPYTUPLE(capi_return,capi_i++,&return_value,#ctype#,\"#ctype#_from_pyobj failed in converting return_value of call-back function #name# to C #ctype#\\n\");
#else
\t\tGETSCALARFROMPYTUPLE(capi_return,capi_i++,return_value,#ctype#,\"#ctype#_from_pyobj failed in converting return_value of call-back function #name# to C #ctype#\\n\");
#endif
""",
                 {debugcapi:"""
#ifdef F2PY_CB_RETURNCOMPLEX
\tfprintf(stderr,\"#showvalueformat#.\\n\",(return_value).r,(return_value).i);
#else
\tfprintf(stderr,\"#showvalueformat#.\\n\",(*return_value).r,(*return_value).i);
#endif

"""}
                 ],
    'return':"""
#ifdef F2PY_CB_RETURNCOMPLEX
\treturn return_value;
#else
\treturn;
#endif
""",
    'need':['#ctype#_from_pyobj',{debugcapi:'CFUNCSMESS'},
            'string.h','GETSCALARFROMPYTUPLE','#ctype#'],
    '_check':iscomplexfunction
    },
    {'docstrout':'\t\t#pydocsignout#',
     'latexdocstrout':['\\item[]{{}\\verb@#pydocsignout#@{}}',
                       {hasnote:'--- #note#'}],
     'docreturn':'#rname#,',
     '_check':isfunction},
    {'_check':issubroutine,'return':'return;'}
    ]

cb_arg_rules=[
    { # Doc
    'docstropt':{l_and(isoptional,isintent_nothide):'\t\t#pydocsign#'},
    'docstrreq':{l_and(isrequired,isintent_nothide):'\t\t#pydocsign#'},
    'docstrout':{isintent_out:'\t\t#pydocsignout#'},
    'latexdocstropt':{l_and(isoptional,isintent_nothide):['\\item[]{{}\\verb@#pydocsign#@{}}',
                                                          {hasnote:'--- #note#'}]},
    'latexdocstrreq':{l_and(isrequired,isintent_nothide):['\\item[]{{}\\verb@#pydocsign#@{}}',
                                                          {hasnote:'--- #note#'}]},
    'latexdocstrout':{isintent_out:['\\item[]{{}\\verb@#pydocsignout#@{}}',
                                    {l_and(hasnote,isintent_hide):'--- #note#',
                                     l_and(hasnote,isintent_nothide):'--- See above.'}]},
    'docsign':{l_and(isrequired,isintent_nothide):'#varname#,'},
    'docsignopt':{l_and(isoptional,isintent_nothide):'#varname#,'},
    'depend':''
    },
    {
    'args':{
    l_and (isscalar,isintent_c):'#ctype# #varname#',
    l_and (isscalar,l_not(isintent_c)):'#ctype# *#varname#_cb_capi',
    isarray:'#ctype# *#varname#',
    isstring:'#ctype# #varname#'
    },
    'args_nm':{
    l_and (isscalar,isintent_c):'#varname#',
    l_and (isscalar,l_not(isintent_c)):'#varname#_cb_capi',
    isarray:'#varname#',
    isstring:'#varname#'
    },
    'args_td':{
    l_and (isscalar,isintent_c):'#ctype#',
    l_and (isscalar,l_not(isintent_c)):'#ctype# *',
    isarray:'#ctype# *',
    isstring:'#ctype#'
    },
     'strarglens':{isstring:',int #varname#_cb_len'}, # untested with multiple args
     'strarglens_td':{isstring:',int'}, # untested with multiple args

     },
    { # Scalars
    'decl':{l_not(isintent_c):'\t#ctype# #varname#=(*#varname#_cb_capi);'},
    'error': {l_and(isintent_c,isintent_out,
                    throw_error('intent(c,out) is forbidden for callback scalar arguments')):\
               ''},
    'frompyobj':[{debugcapi:'\tCFUNCSMESS("cb:Getting #varname#->");'},
                 {isintent_out:'\tif (capi_j>capi_i)\n\t\tGETSCALARFROMPYTUPLE(capi_return,capi_i++,#varname#_cb_capi,#ctype#,"#ctype#_from_pyobj failed in converting argument #varname# of call-back function #name# to C #ctype#\\n");'},
                 {l_and(debugcapi,l_and(l_not(iscomplex),isintent_c)):'\tfprintf(stderr,"#showvalueformat#.\\n",#varname#);'},
                 {l_and(debugcapi,l_and(l_not(iscomplex),l_not(isintent_c))):'\tfprintf(stderr,"#showvalueformat#.\\n",*#varname#_cb_capi);'},
                 {l_and(debugcapi,l_and(iscomplex,isintent_c)):'\tfprintf(stderr,"#showvalueformat#.\\n",(#varname#).r,(#varname#).i);'},
                 {l_and(debugcapi,l_and(iscomplex,l_not(isintent_c))):'\tfprintf(stderr,"#showvalueformat#.\\n",(*#varname#_cb_capi).r,(*#varname#_cb_capi).i);'},
                 ],
    'need':[{isintent_out:['#ctype#_from_pyobj','GETSCALARFROMPYTUPLE']},
            {debugcapi:'CFUNCSMESS'}],
     '_check':isscalar
     },{
    'pyobjfrom':[{isintent_in:"""\
\tif (#name#_nofargs>capi_i)
\t\tif (PyTuple_SetItem((PyObject *)capi_arglist,capi_i++,pyobj_from_#ctype#1(#varname#)))
\t\t\tgoto capi_fail;"""},
                 {isintent_inout:"""\
\tif (#name#_nofargs>capi_i)
\t\tif (PyTuple_SetItem((PyObject *)capi_arglist,capi_i++,pyarr_from_p_#ctype#1(#varname#_cb_capi)))
\t\t\tgoto capi_fail;"""}],
    'need':[{isintent_in:'pyobj_from_#ctype#1'},
            {isintent_inout:'pyarr_from_p_#ctype#1'},
            {iscomplex:'#ctype#'}],
    '_check':l_and(isscalar,isintent_nothide),
    '_optional':''
    },{# String
    'frompyobj':[{debugcapi:'\tCFUNCSMESS("cb:Getting #varname#->\\"");'},
                 """\tif (capi_j>capi_i)
\t\tGETSTRFROMPYTUPLE(capi_return,capi_i++,#varname#,#varname#_cb_len);""",
                 {debugcapi:'\tfprintf(stderr,"#showvalueformat#\\":%d:.\\n",#varname#,#varname#_cb_len);'},
                 ],
    'need':['#ctype#','GETSTRFROMPYTUPLE',
            {debugcapi:'CFUNCSMESS'},'string.h'],
    '_check':l_and(isstring,isintent_out)
    },{
    'pyobjfrom':[{debugcapi:'\tfprintf(stderr,"debug-capi:cb:#varname#=\\"#showvalueformat#\\":%d:\\n",#varname#,#varname#_cb_len);'},
                 {isintent_in:"""\
\tif (#name#_nofargs>capi_i)
\t\tif (PyTuple_SetItem((PyObject *)capi_arglist,capi_i++,pyobj_from_#ctype#1(#varname#)))
\t\t\tgoto capi_fail;"""},
                 {isintent_inout:"""\
\tif (#name#_nofargs>capi_i) {
\t\tint #varname#_cb_dims[] = {#varname#_cb_len};
\t\tif (PyTuple_SetItem((PyObject *)capi_arglist,capi_i++,pyarr_from_p_#ctype#1(#varname#,#varname#_cb_dims)))
\t\t\tgoto capi_fail;
\t}"""}],
    'need':[{isintent_in:'pyobj_from_#ctype#1'},
            {isintent_inout:'pyarr_from_p_#ctype#1'}],
    '_check':l_and(isstring,isintent_nothide),
    '_optional':''
    },
# Array ...
    {
    'decl':'\tnpy_intp #varname#_Dims[#rank#] = {#rank*[-1]#};',
    'setdims':'\t#cbsetdims#;',
    '_check':isarray,
    '_depend':''
    },
    {
    'pyobjfrom':[{debugcapi:'\tfprintf(stderr,"debug-capi:cb:#varname#\\n");'},
                 {isintent_c:"""\
\tif (#name#_nofargs>capi_i) {
\t\tPyArrayObject *tmp_arr = (PyArrayObject *)PyArray_New(&PyArray_Type,#rank#,#varname#_Dims,#atype#,NULL,(char*)#varname#,0,NPY_CARRAY,NULL); /*XXX: Hmm, what will destroy this array??? */
""",
                  l_not(isintent_c):"""\
\tif (#name#_nofargs>capi_i) {
\t\tPyArrayObject *tmp_arr = (PyArrayObject *)PyArray_New(&PyArray_Type,#rank#,#varname#_Dims,#atype#,NULL,(char*)#varname#,0,NPY_FARRAY,NULL); /*XXX: Hmm, what will destroy this array??? */
""",
                  },
                 """
\t\tif (tmp_arr==NULL)
\t\t\tgoto capi_fail;
\t\tif (PyTuple_SetItem((PyObject *)capi_arglist,capi_i++,(PyObject *)tmp_arr))
\t\t\tgoto capi_fail;
}"""],
    '_check':l_and(isarray,isintent_nothide,l_or(isintent_in,isintent_inout)),
    '_optional':'',
    },{
    'frompyobj':[{debugcapi:'\tCFUNCSMESS("cb:Getting #varname#->");'},
                 """\tif (capi_j>capi_i) {
\t\tPyArrayObject *rv_cb_arr = NULL;
\t\tif ((capi_tmp = PyTuple_GetItem(capi_return,capi_i++))==NULL) goto capi_fail;
\t\trv_cb_arr =  array_from_pyobj(#atype#,#varname#_Dims,#rank#,F2PY_INTENT_IN""",
    {isintent_c:'|F2PY_INTENT_C'},
    """,capi_tmp);
\t\tif (rv_cb_arr == NULL) {
\t\t\tfprintf(stderr,\"rv_cb_arr is NULL\\n\");
\t\t\tgoto capi_fail;
\t\t}
\t\tMEMCOPY(#varname#,rv_cb_arr->data,PyArray_NBYTES(rv_cb_arr));
\t\tif (capi_tmp != (PyObject *)rv_cb_arr) {
\t\t\tPy_DECREF(rv_cb_arr);
\t\t}
\t}""",
                 {debugcapi:'\tfprintf(stderr,"<-.\\n");'},
                 ],
    'need':['MEMCOPY',{iscomplexarray:'#ctype#'}],
    '_check':l_and(isarray,isintent_out)
    },{
    'docreturn':'#varname#,',
    '_check':isintent_out
    }
    ]

################## Build call-back module #############
cb_map={}
def buildcallbacks(m):
    global cb_map
    cb_map[m['name']]=[]
    for bi in m['body']:
        if bi['block']=='interface':
            for b in bi['body']:
                if b:
                    buildcallback(b,m['name'])
                else:
                    errmess('warning: empty body for %s\n' % (m['name']))

def buildcallback(rout,um):
    global cb_map
    outmess('\tConstructing call-back function "cb_%s_in_%s"\n'%(rout['name'],um))
    args,depargs=getargs(rout)
    capi_maps.depargs=depargs
    var=rout['vars']
    vrd=capi_maps.cb_routsign2map(rout,um)
    rd=dictappend({},vrd)
    cb_map[um].append([rout['name'],rd['name']])
    for r in cb_rout_rules:
        if (r.has_key('_check') and r['_check'](rout)) or (not r.has_key('_check')):
            ar=applyrules(r,vrd,rout)
            rd=dictappend(rd,ar)
    savevrd={}
    for a in args:
        vrd=capi_maps.cb_sign2map(a,var[a])
        savevrd[a]=vrd
        for r in cb_arg_rules:
            if r.has_key('_depend'): continue
            if r.has_key('_optional') and isoptional(var[a]): continue
            if (r.has_key('_check') and r['_check'](var[a])) or (not r.has_key('_check')):
                ar=applyrules(r,vrd,var[a])
                rd=dictappend(rd,ar)
                if r.has_key('_break'): break
    for a in args:
        vrd=savevrd[a]
        for r in cb_arg_rules:
            if r.has_key('_depend'): continue
            if (not r.has_key('_optional')) or (r.has_key('_optional') and isrequired(var[a])): continue
            if (r.has_key('_check') and r['_check'](var[a])) or (not r.has_key('_check')):
                ar=applyrules(r,vrd,var[a])
                rd=dictappend(rd,ar)
                if r.has_key('_break'): break
    for a in depargs:
        vrd=savevrd[a]
        for r in cb_arg_rules:
            if not r.has_key('_depend'): continue
            if r.has_key('_optional'): continue
            if (r.has_key('_check') and r['_check'](var[a])) or (not r.has_key('_check')):
                ar=applyrules(r,vrd,var[a])
                rd=dictappend(rd,ar)
                if r.has_key('_break'): break
    if rd.has_key('args') and rd.has_key('optargs'):
        if type(rd['optargs'])==type([]):
            rd['optargs']=rd['optargs']+["""
#ifndef F2PY_CB_RETURNCOMPLEX
,
#endif
"""]
            rd['optargs_nm']=rd['optargs_nm']+["""
#ifndef F2PY_CB_RETURNCOMPLEX
,
#endif
"""]
            rd['optargs_td']=rd['optargs_td']+["""
#ifndef F2PY_CB_RETURNCOMPLEX
,
#endif
"""]
    if type(rd['docreturn'])==types.ListType:
        rd['docreturn']=stripcomma(replace('#docreturn#',{'docreturn':rd['docreturn']}))
    optargs=stripcomma(replace('#docsignopt#',
                                {'docsignopt':rd['docsignopt']}
                               ))
    if optargs=='':
        rd['docsignature']=stripcomma(replace('#docsign#',{'docsign':rd['docsign']}))
    else:
        rd['docsignature']=replace('#docsign#[#docsignopt#]',
                                   {'docsign':rd['docsign'],
                                    'docsignopt':optargs,
                                    })
    rd['latexdocsignature']=string.replace(rd['docsignature'],'_','\\_')
    rd['latexdocsignature']=string.replace(rd['latexdocsignature'],',',', ')
    rd['docstrsigns']=[]
    rd['latexdocstrsigns']=[]
    for k in ['docstrreq','docstropt','docstrout','docstrcbs']:
        if rd.has_key(k) and type(rd[k])==types.ListType:
            rd['docstrsigns']=rd['docstrsigns']+rd[k]
        k='latex'+k
        if rd.has_key(k) and type(rd[k])==types.ListType:
            rd['latexdocstrsigns']=rd['latexdocstrsigns']+rd[k][0:1]+\
                                    ['\\begin{description}']+rd[k][1:]+\
                                    ['\\end{description}']
    if not rd.has_key('args'):
        rd['args']=''
        rd['args_td']=''
        rd['args_nm']=''
    if not (rd.get('args') or rd.get('optargs') or rd.get('strarglens')):
        rd['noargs'] = 'void'

    ar=applyrules(cb_routine_rules,rd)
    cfuncs.callbacks[rd['name']]=ar['body']
    if type(ar['need'])==types.StringType:
        ar['need']=[ar['need']]

    if rd.has_key('need'):
        for t in cfuncs.typedefs.keys():
            if t in rd['need']:
                ar['need'].append(t)

    cfuncs.typedefs_generated[rd['name']+'_typedef'] = ar['cbtypedefs']
    ar['need'].append(rd['name']+'_typedef')
    cfuncs.needs[rd['name']]=ar['need']

    capi_maps.lcb2_map[rd['name']]={'maxnofargs':ar['maxnofargs'],
                                    'nofoptargs':ar['nofoptargs'],
                                    'docstr':ar['docstr'],
                                    'latexdocstr':ar['latexdocstr'],
                                    'argname':rd['argname']
                                    }
    outmess('\t  %s\n'%(ar['docstrshort']))
    #print ar['body']
    return
################## Build call-back function #############
