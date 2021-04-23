; ModuleID = 'module'
source_filename = "module"

%literal = type { double, double }
%string_literal = type { double, i8* }

@format_number = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1
@format_true = private unnamed_addr constant [6 x i8] c"true\0A\00", align 1
@format_false = private unnamed_addr constant [7 x i8] c"false\0A\00", align 1
@format_string = private unnamed_addr constant [6 x i8] c"\22%s\22\0A\00", align 1
@format_function = private unnamed_addr constant [17 x i8] c"function object\0A\00", align 1
@format_undef = private unnamed_addr constant [11 x i8] c"undefined\0A\00", align 1
@format_error = private unnamed_addr constant [13 x i8] c"error: \22%s\22\0A\00", align 1
@s = private unnamed_addr constant [4 x i8] c"123\00", align 1
@s.1 = private unnamed_addr constant [4 x i8] c"456\00", align 1
@0 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@s.2 = private unnamed_addr constant [4 x i8] c"789\00", align 1
@s.3 = private unnamed_addr constant [6 x i8] c"!!!!!\00", align 1

declare i8* @malloc(i32)

declare i64 @printf(i8*, ...)

declare i8* @strcpy(i8*, i8*)

declare i32 @strlen(i8*)

declare i8* @strcat(i8*, i8*)

declare void @exit(i32)

define void @display(%literal* %0) {
entry:
  %1 = getelementptr inbounds %literal, %literal* %0, i32 0, i32 0
  %2 = getelementptr inbounds %literal, %literal* %0, i32 0, i32 1
  %3 = load double, double* %1
  %4 = load double, double* %2
  %5 = fcmp oeq double %3, 2.000000e+00
  br i1 %5, label %display_boolean, label %tmp

tmp:                                              ; preds = %entry
  %6 = fcmp oeq double %3, 3.000000e+00
  br i1 %6, label %display_string, label %tmp1

tmp1:                                             ; preds = %tmp
  %7 = fcmp oeq double %3, 4.000000e+00
  br i1 %7, label %display_function, label %tmp2

tmp2:                                             ; preds = %tmp1
  %8 = fcmp oeq double %3, 5.000000e+00
  br i1 %8, label %display_undefined, label %display_number

display_number:                                   ; preds = %tmp2
  %9 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @format_number, i32 0, i32 0), double %4)
  br label %end

display_boolean:                                  ; preds = %entry
  %10 = fcmp oeq double %4, 1.000000e+00
  br i1 %10, label %print_true, label %print_false

print_true:                                       ; preds = %display_boolean
  %11 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @format_true, i32 0, i32 0))
  br label %end

print_false:                                      ; preds = %display_boolean
  %12 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @format_false, i32 0, i32 0))
  br label %end

display_string:                                   ; preds = %tmp
  %13 = bitcast double %4 to i64
  %14 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @format_string, i32 0, i32 0), i64 %13)
  br label %end

display_function:                                 ; preds = %tmp1
  %15 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @format_function, i32 0, i32 0))
  br label %end

display_undefined:                                ; preds = %tmp2
  %16 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @format_undef, i32 0, i32 0))
  br label %end

end:                                              ; preds = %display_undefined, %display_function, %display_string, %print_false, %print_true, %display_number
  ret void
}

define void @error(i8* %0) {
entry:
  %1 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @format_error, i32 0, i32 0), i8* %0)
  call void @exit(i32 1)
  ret void
}

define i8* @strconcat(i8* %0, i8* %1) {
entry:
  %2 = call i32 @strlen(i8* %0)
  %3 = call i32 @strlen(i8* %1)
  %4 = add i32 %2, %3
  %5 = add i32 %4, 1
  %6 = call i8* @malloc(i32 %5)
  %7 = call i8* @strcpy(i8* %6, i8* %0)
  %8 = call i8* @strcat(i8* %6, i8* %1)
  ret i8* %6
}

define i32 @main() {
entry:
  %env = call i8* @malloc(i32 8)
  %0 = bitcast i8* %env to %literal**
  %1 = call i8* @malloc(i32 16)
  %2 = bitcast i8* %1 to %literal*
  %3 = getelementptr inbounds %literal, %literal* %2, i32 0, i32 0
  %4 = getelementptr inbounds %literal, %literal* %2, i32 0, i32 1
  store double 5.000000e+00, double* %3
  store double 0.000000e+00, double* %4
  %env1 = call i8* @malloc(i32 8)
  %5 = bitcast i8* %env1 to %literal**
  %6 = bitcast %literal** %5 to %literal***
  store %literal** %0, %literal*** %6
  %7 = call i8* @malloc(i32 16)
  %8 = bitcast i8* %7 to %literal*
  %9 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %10 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  store double 5.000000e+00, double* %9
  store double 0.000000e+00, double* %10
  %11 = call i8* @malloc(i32 16)
  %12 = bitcast i8* %11 to %string_literal*
  %13 = getelementptr inbounds %string_literal, %string_literal* %12, i32 0, i32 0
  %14 = getelementptr inbounds %string_literal, %string_literal* %12, i32 0, i32 1
  store double 3.000000e+00, double* %13
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @s, i32 0, i32 0), i8** %14
  %15 = bitcast %string_literal* %12 to %literal*
  %16 = call i8* @malloc(i32 16)
  %17 = bitcast i8* %16 to %string_literal*
  %18 = getelementptr inbounds %string_literal, %string_literal* %17, i32 0, i32 0
  %19 = getelementptr inbounds %string_literal, %string_literal* %17, i32 0, i32 1
  store double 3.000000e+00, double* %18
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @s.1, i32 0, i32 0), i8** %19
  %20 = bitcast %string_literal* %17 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %15, i32 0, i32 1
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  %23 = load double, double* %21
  %24 = load double, double* %22
  %25 = getelementptr inbounds %literal, %literal* %15, i32 0, i32 0
  %26 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %27 = load double, double* %25
  %28 = load double, double* %26
  %29 = fcmp oeq double %27, 1.000000e+00
  br i1 %29, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %entry
  %30 = fcmp oeq double %28, 1.000000e+00
  br i1 %30, label %add.num, label %add.err

add.cstr1:                                        ; preds = %entry
  %31 = fcmp oeq double %27, 3.000000e+00
  br i1 %31, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %32 = fcmp oeq double %28, 3.000000e+00
  br i1 %32, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %33 = load double, double* %21
  %34 = load double, double* %22
  %35 = fadd double %33, %34
  %36 = call i8* @malloc(i32 16)
  %37 = bitcast i8* %36 to %literal*
  %38 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 0
  %39 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 1
  store double 1.000000e+00, double* %38
  store double %35, double* %39
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %40 = bitcast %literal* %15 to %string_literal*
  %41 = bitcast %literal* %20 to %string_literal*
  %42 = getelementptr inbounds %string_literal, %string_literal* %40, i32 0, i32 1
  %43 = getelementptr inbounds %string_literal, %string_literal* %41, i32 0, i32 1
  %44 = load i8*, i8** %42
  %45 = load i8*, i8** %43
  %46 = call i8* @strconcat(i8* %44, i8* %45)
  %47 = call i8* @malloc(i32 16)
  %48 = bitcast i8* %47 to %string_literal*
  %49 = getelementptr inbounds %string_literal, %string_literal* %48, i32 0, i32 0
  %50 = getelementptr inbounds %string_literal, %string_literal* %48, i32 0, i32 1
  store double 3.000000e+00, double* %49
  store i8* %46, i8** %50
  %51 = bitcast %string_literal* %48 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %52 = phi %literal* [ %37, %add.num ], [ %51, %add.str ]
  %53 = call i8* @malloc(i32 16)
  %54 = bitcast i8* %53 to %string_literal*
  %55 = getelementptr inbounds %string_literal, %string_literal* %54, i32 0, i32 0
  %56 = getelementptr inbounds %string_literal, %string_literal* %54, i32 0, i32 1
  store double 3.000000e+00, double* %55
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @s.2, i32 0, i32 0), i8** %56
  %57 = bitcast %string_literal* %54 to %literal*
  %58 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 1
  %59 = getelementptr inbounds %literal, %literal* %57, i32 0, i32 1
  %60 = load double, double* %58
  %61 = load double, double* %59
  %62 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 0
  %63 = getelementptr inbounds %literal, %literal* %57, i32 0, i32 0
  %64 = load double, double* %62
  %65 = load double, double* %63
  %66 = fcmp oeq double %64, 1.000000e+00
  br i1 %66, label %add.num12, label %add.cstr13

add.num12:                                        ; preds = %add.end
  %67 = fcmp oeq double %65, 1.000000e+00
  br i1 %67, label %add.num6, label %add.err5

add.cstr13:                                       ; preds = %add.end
  %68 = fcmp oeq double %64, 3.000000e+00
  br i1 %68, label %add.cstr24, label %add.err5

add.cstr24:                                       ; preds = %add.cstr13
  %69 = fcmp oeq double %65, 3.000000e+00
  br i1 %69, label %add.str7, label %add.err5

add.err5:                                         ; preds = %add.cstr24, %add.cstr13, %add.num12
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num6

add.num6:                                         ; preds = %add.err5, %add.num12
  %70 = load double, double* %58
  %71 = load double, double* %59
  %72 = fadd double %70, %71
  %73 = call i8* @malloc(i32 16)
  %74 = bitcast i8* %73 to %literal*
  %75 = getelementptr inbounds %literal, %literal* %74, i32 0, i32 0
  %76 = getelementptr inbounds %literal, %literal* %74, i32 0, i32 1
  store double 1.000000e+00, double* %75
  store double %72, double* %76
  br label %add.end8

add.str7:                                         ; preds = %add.cstr24
  %77 = bitcast %literal* %52 to %string_literal*
  %78 = bitcast %literal* %57 to %string_literal*
  %79 = getelementptr inbounds %string_literal, %string_literal* %77, i32 0, i32 1
  %80 = getelementptr inbounds %string_literal, %string_literal* %78, i32 0, i32 1
  %81 = load i8*, i8** %79
  %82 = load i8*, i8** %80
  %83 = call i8* @strconcat(i8* %81, i8* %82)
  %84 = call i8* @malloc(i32 16)
  %85 = bitcast i8* %84 to %string_literal*
  %86 = getelementptr inbounds %string_literal, %string_literal* %85, i32 0, i32 0
  %87 = getelementptr inbounds %string_literal, %string_literal* %85, i32 0, i32 1
  store double 3.000000e+00, double* %86
  store i8* %83, i8** %87
  %88 = bitcast %string_literal* %85 to %literal*
  br label %add.end8

add.end8:                                         ; preds = %add.str7, %add.num6
  %89 = phi %literal* [ %74, %add.num6 ], [ %88, %add.str7 ]
  %90 = call i8* @malloc(i32 16)
  %91 = bitcast i8* %90 to %string_literal*
  %92 = getelementptr inbounds %string_literal, %string_literal* %91, i32 0, i32 0
  %93 = getelementptr inbounds %string_literal, %string_literal* %91, i32 0, i32 1
  store double 3.000000e+00, double* %92
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @s.3, i32 0, i32 0), i8** %93
  %94 = bitcast %string_literal* %91 to %literal*
  %95 = getelementptr inbounds %literal, %literal* %89, i32 0, i32 1
  %96 = getelementptr inbounds %literal, %literal* %94, i32 0, i32 1
  %97 = load double, double* %95
  %98 = load double, double* %96
  %99 = getelementptr inbounds %literal, %literal* %89, i32 0, i32 0
  %100 = getelementptr inbounds %literal, %literal* %94, i32 0, i32 0
  %101 = load double, double* %99
  %102 = load double, double* %100
  %103 = fcmp oeq double %101, 1.000000e+00
  br i1 %103, label %add.num19, label %add.cstr110

add.num19:                                        ; preds = %add.end8
  %104 = fcmp oeq double %102, 1.000000e+00
  br i1 %104, label %add.num13, label %add.err12

add.cstr110:                                      ; preds = %add.end8
  %105 = fcmp oeq double %101, 3.000000e+00
  br i1 %105, label %add.cstr211, label %add.err12

add.cstr211:                                      ; preds = %add.cstr110
  %106 = fcmp oeq double %102, 3.000000e+00
  br i1 %106, label %add.str14, label %add.err12

add.err12:                                        ; preds = %add.cstr211, %add.cstr110, %add.num19
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num13

add.num13:                                        ; preds = %add.err12, %add.num19
  %107 = load double, double* %95
  %108 = load double, double* %96
  %109 = fadd double %107, %108
  %110 = call i8* @malloc(i32 16)
  %111 = bitcast i8* %110 to %literal*
  %112 = getelementptr inbounds %literal, %literal* %111, i32 0, i32 0
  %113 = getelementptr inbounds %literal, %literal* %111, i32 0, i32 1
  store double 1.000000e+00, double* %112
  store double %109, double* %113
  br label %add.end15

add.str14:                                        ; preds = %add.cstr211
  %114 = bitcast %literal* %89 to %string_literal*
  %115 = bitcast %literal* %94 to %string_literal*
  %116 = getelementptr inbounds %string_literal, %string_literal* %114, i32 0, i32 1
  %117 = getelementptr inbounds %string_literal, %string_literal* %115, i32 0, i32 1
  %118 = load i8*, i8** %116
  %119 = load i8*, i8** %117
  %120 = call i8* @strconcat(i8* %118, i8* %119)
  %121 = call i8* @malloc(i32 16)
  %122 = bitcast i8* %121 to %string_literal*
  %123 = getelementptr inbounds %string_literal, %string_literal* %122, i32 0, i32 0
  %124 = getelementptr inbounds %string_literal, %string_literal* %122, i32 0, i32 1
  store double 3.000000e+00, double* %123
  store i8* %120, i8** %124
  %125 = bitcast %string_literal* %122 to %literal*
  br label %add.end15

add.end15:                                        ; preds = %add.str14, %add.num13
  %126 = phi %literal* [ %111, %add.num13 ], [ %125, %add.str14 ]
  call void @display(%literal* %126)
  ret i32 0
}

