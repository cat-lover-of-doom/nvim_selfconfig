package main

import (
	"fmt"
	"go/ast"
	"go/parser"
	"log"
	"os"
	"strings"
	"text/template"
	// "bufio"
	"go/token"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

type TestCase struct {
	Name        string
	FuncName    string
	Arguments   []string
	Returns     []string
	PackageName string
}

func main() {
	func_name := os.Args[1]
	expr := fmt.Sprintf(`package main
%s}
`, func_name)
	funcDetails, err := getFunctionDetails(expr)

	if err != nil {
		log.Fatalf("could not get function details: %v", err)
	}

    run_template(funcDetails)
}

func getFunctionDetails(expr string) (TestCase, error) {
	fset := token.NewFileSet()

	// Parse the wrapped code
	node, err := parser.ParseFile(fset, "", expr, parser.AllErrors)
	if err != nil {
		return TestCase{}, err
	}

    test := TestCase{}
	decl := node.Decls[0]
	if funcDecl, ok := decl.(*ast.FuncDecl); ok {
		arguments := extractFieldList(funcDecl.Type.Params)
		returns := extractFieldList(funcDecl.Type.Results)

        test = TestCase{
			Name:        fmt.Sprintf("Test%s", cases.Title(language.English, cases.Compact).String(funcDecl.Name.Name)),
			FuncName:    funcDecl.Name.Name,
			Arguments:   arguments,
			Returns:     returns,
		}
	}

	return test, nil
}

func extractFieldList(fields *ast.FieldList) []string {
	if fields == nil {
		return []string{}
	}

	var parts []string
	for _, field := range fields.List {
		typeStr := fieldTypeToString(field.Type)
		for _, name := range field.Names {
			parts = append(parts, fmt.Sprintf("%s %s", name.Name, typeStr))
		}
		if len(field.Names) == 0 {
			parts = append(parts, typeStr)
		}
	}

	return parts
}

func fieldTypeToString(expr ast.Expr) string {
	switch t := expr.(type) {
	case *ast.Ident:
		return t.Name
	case *ast.SelectorExpr:
		return fmt.Sprintf("%s.%s", fieldTypeToString(t.X), t.Sel.Name)
	case *ast.StarExpr:
		return "*" + fieldTypeToString(t.X)
	case *ast.ArrayType:
		return "[]" + fieldTypeToString(t.Elt)
	case *ast.FuncType:
		return "func"
	default:
		return ""
	}
}

func run_template(tc TestCase) {
	funcMap := map[string]interface{}{
		"unpackReturns":        unpackReturns,
		"unpackReturnsDeclare": unpackReturnsDeclare,
		"unpackArgs":           unpackArgs,
		"unpackArgsDeclare":    unpackArgsDeclare,
		"unpackAssertions":     unpackAssertions,
	}
	tmpl := template.Must(template.New("test").Funcs(funcMap).Parse(testTemplate))
    err := tmpl.Execute(os.Stdout, tc)
	if err != nil {
		log.Fatalf("could not write to test file: %v", err)
	}

}

func unpackArgsDeclare(args []string) string {
	newArgs := make([]string, 0)
	for _, element := range args {
		elementName := strings.Split(element, " ")[0]
		newArgs = append(newArgs, fmt.Sprintf("tt.args.%v", elementName))
	}
	return strings.Join(newArgs, ", ")
}

func unpackArgs(args []string) string {
	newArgs := make([]string, 0)
	for _, element := range args {
		newArgs = append(newArgs, fmt.Sprintf("%v", element))
	}
	return strings.Join(newArgs, "\n")
}

func unpackReturnsDeclare(want []string) string {
	newWant := make([]string, 0)
	for index := range want {
		newWant = append(newWant, fmt.Sprintf("want%v", index))
	}
	return strings.Join(newWant, ", ")
}

func unpackAssertions(want []string) string {
	newAssertions := make([]string, 0)
	for index, element := range want {
		if strings.HasPrefix(element, "[]") {
			newAssertions = append(newAssertions, fmt.Sprintf("for i, v := range want%v {\n\tif v != tt.want.want%v[i] {\n\t\tt.Errorf(\"element %%d of want%v: want %%v, got %%v\", i, v, tt.want.want%v[i])\n\t}\n}", index, index, index, index))
		} else {
			newAssertions = append(newAssertions, fmt.Sprintf("if want%v != tt.want.want%v {\n\tt.Errorf(\"want%v: want %%v, got %%v\", want%v, tt.want.want%v)\n}", index, index, index, index, index))
		}
	}
	return strings.Join(newAssertions, "\n")
}

func unpackReturns(want []string) string {
	newWant := make([]string, 0)
	for index, element := range want {
		newWant = append(newWant, fmt.Sprintf("want%v %v", index, element))
	}
	return strings.Join(newWant, "\n")
}

const testTemplate = `func {{ .Name }}(t *testing.T) {
	tests := []struct {
		name string
		{{- if .Arguments }}
		args struct {
            {{ unpackArgs .Arguments }}
		}
		{{- end }}
		want struct {
			{{ unpackReturns .Returns }}
		}
	}{
		// Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
            {{ unpackReturnsDeclare .Returns}} := {{ .FuncName }}({{ unpackArgsDeclare .Arguments}})
            {{ unpackAssertions .Returns}}
		})
	}
}
`
