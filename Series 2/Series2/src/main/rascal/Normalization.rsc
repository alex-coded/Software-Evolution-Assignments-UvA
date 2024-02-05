module Normalization

import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import Set;
import String;
import Map;
import util::Math;
import Relation; 
import Type;
import DateTime;
import lang::java::m3::TypeSymbol;
import util::UUID;
import Node;
import util::Math;
import Boolean;
import lang::json::IO;


@memo
public list[Declaration] normalizeASTNodes(list[Declaration] declarations) {

	return bottom-up visit (declarations) {
		case \simpleName(_) =>{
		    \simpleName("");
		}
		case \variable(_, int extra) => {
			variable("", extra);
		}
		case \variable(_, int extra, Expression \initializer) => {
			variable("", extra, initializer);
		}
		case \method(Type \return, _, list[Declaration] parameters, list[Expression] exceptions, Statement impl)  => {
			\method(\return, "", parameters,  exceptions, impl);
		}
		case \method(Type \return, _, list[Declaration] parameters, list[Expression] exceptions)  => {
			\method(\return, "", parameters,  exceptions);
		}
        case \vararg(Type \type, _) => {
            \vararg(\type, "");
        }
		case \typeParameter(_ , list[Type] extendsList) => {
			\typeParameter("", extendsList);
		}
        case \fieldAccess(bool isSuper, Expression expression, "") =>{
            \fieldAccess(isSuper, expression, "");
        }
		case \parameter(Type \type, _, int extraDimensions)=> {
			\parameter(\type, "", extraDimensions);
		}
		case \constructor(_, list[Declaration] parameters, list[Expression] exceptions, Statement impl) => {
			\constructor("", parameters, exceptions, impl);
		}
        case \simpleName(_) =>{
            \simpleName("");
        }
	};
}

