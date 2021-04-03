; ModuleID = 'module'
source_filename = "module"

%literal = type { double, double }
%function_literal = type { double, %literal**, %literal* (%literal**, %literal**)* }
%string_literal = type { double, i8* }

@format_number = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1
@format_true = private unnamed_addr constant [6 x i8] c"true\0A\00", align 1
@format_false = private unnamed_addr constant [7 x i8] c"false\0A\00", align 1
@format_string = private unnamed_addr constant [6 x i8] c"\22%s\22\0A\00", align 1
@format_function = private unnamed_addr constant [17 x i8] c"function object\0A\00", align 1
@format_undef = private unnamed_addr constant [11 x i8] c"undefined\0A\00", align 1
@format_error = private unnamed_addr constant [13 x i8] c"error: \22%s\22\0A\00", align 1
@0 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@1 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@2 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@3 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1

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
  %env1 = call i8* @malloc(i32 16)
  %5 = bitcast i8* %env1 to %literal**
  %6 = bitcast %literal** %5 to %literal***
  store %literal** %0, %literal*** %6
  %7 = call i8* @malloc(i32 16)
  %8 = bitcast i8* %7 to %literal*
  %9 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %10 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  store double 5.000000e+00, double* %9
  store double 0.000000e+00, double* %10
  %11 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store volatile %literal* %8, %literal** %11
  %12 = call i8* @malloc(i32 16)
  %13 = bitcast i8* %12 to %function_literal*
  %14 = getelementptr inbounds %function_literal, %function_literal* %13, i32 0, i32 0
  %15 = getelementptr inbounds %function_literal, %function_literal* %13, i32 0, i32 1
  %16 = getelementptr inbounds %function_literal, %function_literal* %13, i32 0, i32 2
  store double 4.000000e+00, double* %14
  store %literal** %5, %literal*** %15
  store %literal* (%literal**, %literal**)* @__anon, %literal* (%literal**, %literal**)** %16
  %17 = bitcast %function_literal* %13 to %literal*
  %18 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %17, %literal** %18
  %19 = call i8* @malloc(i32 16)
  %20 = bitcast i8* %19 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  store double 1.000000e+00, double* %21
  store double 0.000000e+00, double* %22
  %23 = getelementptr inbounds %literal*, %literal** %5, i32 1
  %24 = load %literal*, %literal** %23
  %25 = getelementptr inbounds %literal, %literal* %24, i32 0, i32 0
  %26 = load double, double* %25
  %27 = fcmp oeq double %26, 4.000000e+00
  br i1 %27, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @3, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %entry
  %28 = bitcast %literal* %24 to %function_literal*
  %29 = getelementptr inbounds %function_literal, %function_literal* %28, i32 0, i32 2
  %30 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %29
  %31 = getelementptr inbounds %function_literal, %function_literal* %28, i32 0, i32 1
  %32 = load %literal**, %literal*** %31
  %params = call i8* @malloc(i32 8)
  %33 = bitcast i8* %params to %literal**
  %34 = getelementptr inbounds %literal*, %literal** %33, i32 0
  store %literal* %20, %literal** %34
  %35 = call %literal* %30(%literal** %32, %literal** %33)
  call void @display(%literal* %35)
  ret i32 0
}

define %literal* @__anon(%literal** %0, %literal** %1) {
f.setup:
  %env = call i8* @malloc(i32 16)
  %2 = bitcast i8* %env to %literal**
  %3 = bitcast %literal** %2 to %literal***
  store %literal** %0, %literal*** %3
  %4 = getelementptr inbounds %literal*, %literal** %1, i32 0
  %5 = load %literal*, %literal** %4
  %6 = getelementptr inbounds %literal*, %literal** %2, i32 1
  store %literal* %5, %literal** %6
  br label %f.entry

f.entry:                                          ; preds = %f.setup
  %env1 = call i8* @malloc(i32 24)
  %7 = bitcast i8* %env1 to %literal**
  %8 = bitcast %literal** %7 to %literal***
  store %literal** %2, %literal*** %8
  %9 = call i8* @malloc(i32 16)
  %10 = bitcast i8* %9 to %literal*
  %11 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 0
  %12 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 1
  store double 5.000000e+00, double* %11
  store double 0.000000e+00, double* %12
  %13 = getelementptr inbounds %literal*, %literal** %7, i32 1
  store volatile %literal* %10, %literal** %13
  %14 = getelementptr inbounds %literal*, %literal** %7, i32 2
  store volatile %literal* %10, %literal** %14
  %15 = bitcast %literal** %7 to %literal***
  %16 = load %literal**, %literal*** %15
  %17 = getelementptr inbounds %literal*, %literal** %16, i32 1
  %18 = load %literal*, %literal** %17
  %19 = call i8* @malloc(i32 16)
  %20 = bitcast i8* %19 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  store double 1.000000e+00, double* %21
  store double 1.000000e+00, double* %22
  %23 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 1
  %24 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  %25 = load double, double* %23
  %26 = load double, double* %24
  %27 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 0
  %28 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %29 = load double, double* %27
  %30 = load double, double* %28
  %31 = fcmp oeq double %29, 1.000000e+00
  br i1 %31, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %f.entry
  %32 = fcmp oeq double %30, 1.000000e+00
  br i1 %32, label %add.num, label %add.err

add.cstr1:                                        ; preds = %f.entry
  %33 = fcmp oeq double %29, 3.000000e+00
  br i1 %33, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %34 = fcmp oeq double %30, 3.000000e+00
  br i1 %34, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %35 = load double, double* %23
  %36 = load double, double* %24
  %37 = fadd double %35, %36
  %38 = call i8* @malloc(i32 16)
  %39 = bitcast i8* %38 to %literal*
  %40 = getelementptr inbounds %literal, %literal* %39, i32 0, i32 0
  %41 = getelementptr inbounds %literal, %literal* %39, i32 0, i32 1
  store double 1.000000e+00, double* %40
  store double %37, double* %41
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %42 = bitcast %literal* %18 to %string_literal*
  %43 = bitcast %literal* %20 to %string_literal*
  %44 = getelementptr inbounds %string_literal, %string_literal* %42, i32 0, i32 1
  %45 = getelementptr inbounds %string_literal, %string_literal* %43, i32 0, i32 1
  %46 = load i8*, i8** %44
  %47 = load i8*, i8** %45
  %48 = call i8* @strconcat(i8* %46, i8* %47)
  %49 = call i8* @malloc(i32 16)
  %50 = bitcast i8* %49 to %string_literal*
  %51 = getelementptr inbounds %string_literal, %string_literal* %50, i32 0, i32 0
  %52 = getelementptr inbounds %string_literal, %string_literal* %50, i32 0, i32 1
  store double 3.000000e+00, double* %51
  store i8* %48, i8** %52
  %53 = bitcast %string_literal* %50 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %54 = phi %literal* [ %39, %add.num ], [ %53, %add.str ]
  %55 = getelementptr inbounds %literal*, %literal** %7, i32 1
  store %literal* %54, %literal** %55
  %56 = getelementptr inbounds %literal*, %literal** %7, i32 1
  %57 = load %literal*, %literal** %56
  %58 = call i8* @malloc(i32 16)
  %59 = bitcast i8* %58 to %literal*
  %60 = getelementptr inbounds %literal, %literal* %59, i32 0, i32 0
  %61 = getelementptr inbounds %literal, %literal* %59, i32 0, i32 1
  store double 1.000000e+00, double* %60
  store double 1.000000e+01, double* %61
  %62 = getelementptr inbounds %literal, %literal* %57, i32 0, i32 1
  %63 = getelementptr inbounds %literal, %literal* %59, i32 0, i32 1
  %64 = load double, double* %62
  %65 = load double, double* %63
  %66 = getelementptr inbounds %literal, %literal* %57, i32 0, i32 0
  %67 = getelementptr inbounds %literal, %literal* %59, i32 0, i32 0
  %68 = load double, double* %66
  %69 = load double, double* %67
  %70 = fcmp oeq double %68, 1.000000e+00
  br i1 %70, label %add.num12, label %add.cstr13

add.num12:                                        ; preds = %add.end
  %71 = fcmp oeq double %69, 1.000000e+00
  br i1 %71, label %add.num6, label %add.err5

add.cstr13:                                       ; preds = %add.end
  %72 = fcmp oeq double %68, 3.000000e+00
  br i1 %72, label %add.cstr24, label %add.err5

add.cstr24:                                       ; preds = %add.cstr13
  %73 = fcmp oeq double %69, 3.000000e+00
  br i1 %73, label %add.str7, label %add.err5

add.err5:                                         ; preds = %add.cstr24, %add.cstr13, %add.num12
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num6

add.num6:                                         ; preds = %add.err5, %add.num12
  %74 = load double, double* %62
  %75 = load double, double* %63
  %76 = fadd double %74, %75
  %77 = call i8* @malloc(i32 16)
  %78 = bitcast i8* %77 to %literal*
  %79 = getelementptr inbounds %literal, %literal* %78, i32 0, i32 0
  %80 = getelementptr inbounds %literal, %literal* %78, i32 0, i32 1
  store double 1.000000e+00, double* %79
  store double %76, double* %80
  br label %add.end8

add.str7:                                         ; preds = %add.cstr24
  %81 = bitcast %literal* %57 to %string_literal*
  %82 = bitcast %literal* %59 to %string_literal*
  %83 = getelementptr inbounds %string_literal, %string_literal* %81, i32 0, i32 1
  %84 = getelementptr inbounds %string_literal, %string_literal* %82, i32 0, i32 1
  %85 = load i8*, i8** %83
  %86 = load i8*, i8** %84
  %87 = call i8* @strconcat(i8* %85, i8* %86)
  %88 = call i8* @malloc(i32 16)
  %89 = bitcast i8* %88 to %string_literal*
  %90 = getelementptr inbounds %string_literal, %string_literal* %89, i32 0, i32 0
  %91 = getelementptr inbounds %string_literal, %string_literal* %89, i32 0, i32 1
  store double 3.000000e+00, double* %90
  store i8* %87, i8** %91
  %92 = bitcast %string_literal* %89 to %literal*
  br label %add.end8

add.end8:                                         ; preds = %add.str7, %add.num6
  %93 = phi %literal* [ %78, %add.num6 ], [ %92, %add.str7 ]
  %94 = getelementptr inbounds %literal*, %literal** %7, i32 2
  store %literal* %93, %literal** %94
  %95 = getelementptr inbounds %literal*, %literal** %7, i32 2
  %96 = load %literal*, %literal** %95
  %97 = call i8* @malloc(i32 16)
  %98 = bitcast i8* %97 to %literal*
  %99 = getelementptr inbounds %literal, %literal* %98, i32 0, i32 0
  %100 = getelementptr inbounds %literal, %literal* %98, i32 0, i32 1
  store double 1.000000e+00, double* %99
  store double 1.000000e+02, double* %100
  %101 = getelementptr inbounds %literal, %literal* %96, i32 0, i32 1
  %102 = getelementptr inbounds %literal, %literal* %98, i32 0, i32 1
  %103 = load double, double* %101
  %104 = load double, double* %102
  %105 = getelementptr inbounds %literal, %literal* %96, i32 0, i32 0
  %106 = getelementptr inbounds %literal, %literal* %98, i32 0, i32 0
  %107 = load double, double* %105
  %108 = load double, double* %106
  %109 = fcmp oeq double %107, 1.000000e+00
  br i1 %109, label %add.num19, label %add.cstr110

add.num19:                                        ; preds = %add.end8
  %110 = fcmp oeq double %108, 1.000000e+00
  br i1 %110, label %add.num13, label %add.err12

add.cstr110:                                      ; preds = %add.end8
  %111 = fcmp oeq double %107, 3.000000e+00
  br i1 %111, label %add.cstr211, label %add.err12

add.cstr211:                                      ; preds = %add.cstr110
  %112 = fcmp oeq double %108, 3.000000e+00
  br i1 %112, label %add.str14, label %add.err12

add.err12:                                        ; preds = %add.cstr211, %add.cstr110, %add.num19
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @2, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num13

add.num13:                                        ; preds = %add.err12, %add.num19
  %113 = load double, double* %101
  %114 = load double, double* %102
  %115 = fadd double %113, %114
  %116 = call i8* @malloc(i32 16)
  %117 = bitcast i8* %116 to %literal*
  %118 = getelementptr inbounds %literal, %literal* %117, i32 0, i32 0
  %119 = getelementptr inbounds %literal, %literal* %117, i32 0, i32 1
  store double 1.000000e+00, double* %118
  store double %115, double* %119
  br label %add.end15

add.str14:                                        ; preds = %add.cstr211
  %120 = bitcast %literal* %96 to %string_literal*
  %121 = bitcast %literal* %98 to %string_literal*
  %122 = getelementptr inbounds %string_literal, %string_literal* %120, i32 0, i32 1
  %123 = getelementptr inbounds %string_literal, %string_literal* %121, i32 0, i32 1
  %124 = load i8*, i8** %122
  %125 = load i8*, i8** %123
  %126 = call i8* @strconcat(i8* %124, i8* %125)
  %127 = call i8* @malloc(i32 16)
  %128 = bitcast i8* %127 to %string_literal*
  %129 = getelementptr inbounds %string_literal, %string_literal* %128, i32 0, i32 0
  %130 = getelementptr inbounds %string_literal, %string_literal* %128, i32 0, i32 1
  store double 3.000000e+00, double* %129
  store i8* %126, i8** %130
  %131 = bitcast %string_literal* %128 to %literal*
  br label %add.end15

add.end15:                                        ; preds = %add.str14, %add.num13
  %132 = phi %literal* [ %117, %add.num13 ], [ %131, %add.str14 ]
  ret %literal* %132
}

