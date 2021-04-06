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
  store %literal* %8, %literal** %11
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
  %23 = getelementptr inbounds %literal, %literal* %17, i32 0, i32 0
  %24 = load double, double* %23
  %25 = fcmp oeq double %24, 4.000000e+00
  br i1 %25, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @3, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %entry
  %26 = bitcast %literal* %17 to %function_literal*
  %27 = getelementptr inbounds %function_literal, %function_literal* %26, i32 0, i32 2
  %28 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %27
  %29 = getelementptr inbounds %function_literal, %function_literal* %26, i32 0, i32 1
  %30 = load %literal**, %literal*** %29
  %params = call i8* @malloc(i32 8)
  %31 = bitcast i8* %params to %literal**
  %32 = getelementptr inbounds %literal*, %literal** %31, i32 0
  store %literal* %20, %literal** %32
  %33 = call %literal* %28(%literal** %30, %literal** %31)
  call void @display(%literal* %33)
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
  store %literal* %10, %literal** %13
  %14 = getelementptr inbounds %literal*, %literal** %7, i32 2
  store %literal* %10, %literal** %14
  %15 = call i8* @malloc(i32 16)
  %16 = bitcast i8* %15 to %literal*
  %17 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 0
  %18 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 1
  store double 1.000000e+00, double* %17
  store double 1.000000e+00, double* %18
  %19 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %20 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 1
  %21 = load double, double* %19
  %22 = load double, double* %20
  %23 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %24 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 0
  %25 = load double, double* %23
  %26 = load double, double* %24
  %27 = fcmp oeq double %25, 1.000000e+00
  br i1 %27, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %f.entry
  %28 = fcmp oeq double %26, 1.000000e+00
  br i1 %28, label %add.num, label %add.err

add.cstr1:                                        ; preds = %f.entry
  %29 = fcmp oeq double %25, 3.000000e+00
  br i1 %29, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %30 = fcmp oeq double %26, 3.000000e+00
  br i1 %30, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %31 = load double, double* %19
  %32 = load double, double* %20
  %33 = fadd double %31, %32
  %34 = call i8* @malloc(i32 16)
  %35 = bitcast i8* %34 to %literal*
  %36 = getelementptr inbounds %literal, %literal* %35, i32 0, i32 0
  %37 = getelementptr inbounds %literal, %literal* %35, i32 0, i32 1
  store double 1.000000e+00, double* %36
  store double %33, double* %37
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %38 = bitcast %literal* %5 to %string_literal*
  %39 = bitcast %literal* %16 to %string_literal*
  %40 = getelementptr inbounds %string_literal, %string_literal* %38, i32 0, i32 1
  %41 = getelementptr inbounds %string_literal, %string_literal* %39, i32 0, i32 1
  %42 = load i8*, i8** %40
  %43 = load i8*, i8** %41
  %44 = call i8* @strconcat(i8* %42, i8* %43)
  %45 = call i8* @malloc(i32 16)
  %46 = bitcast i8* %45 to %string_literal*
  %47 = getelementptr inbounds %string_literal, %string_literal* %46, i32 0, i32 0
  %48 = getelementptr inbounds %string_literal, %string_literal* %46, i32 0, i32 1
  store double 3.000000e+00, double* %47
  store i8* %44, i8** %48
  %49 = bitcast %string_literal* %46 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %50 = phi %literal* [ %35, %add.num ], [ %49, %add.str ]
  %51 = getelementptr inbounds %literal*, %literal** %7, i32 1
  store %literal* %50, %literal** %51
  %52 = call i8* @malloc(i32 16)
  %53 = bitcast i8* %52 to %literal*
  %54 = getelementptr inbounds %literal, %literal* %53, i32 0, i32 0
  %55 = getelementptr inbounds %literal, %literal* %53, i32 0, i32 1
  store double 1.000000e+00, double* %54
  store double 1.000000e+01, double* %55
  %56 = getelementptr inbounds %literal, %literal* %50, i32 0, i32 1
  %57 = getelementptr inbounds %literal, %literal* %53, i32 0, i32 1
  %58 = load double, double* %56
  %59 = load double, double* %57
  %60 = getelementptr inbounds %literal, %literal* %50, i32 0, i32 0
  %61 = getelementptr inbounds %literal, %literal* %53, i32 0, i32 0
  %62 = load double, double* %60
  %63 = load double, double* %61
  %64 = fcmp oeq double %62, 1.000000e+00
  br i1 %64, label %add.num12, label %add.cstr13

add.num12:                                        ; preds = %add.end
  %65 = fcmp oeq double %63, 1.000000e+00
  br i1 %65, label %add.num6, label %add.err5

add.cstr13:                                       ; preds = %add.end
  %66 = fcmp oeq double %62, 3.000000e+00
  br i1 %66, label %add.cstr24, label %add.err5

add.cstr24:                                       ; preds = %add.cstr13
  %67 = fcmp oeq double %63, 3.000000e+00
  br i1 %67, label %add.str7, label %add.err5

add.err5:                                         ; preds = %add.cstr24, %add.cstr13, %add.num12
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num6

add.num6:                                         ; preds = %add.err5, %add.num12
  %68 = load double, double* %56
  %69 = load double, double* %57
  %70 = fadd double %68, %69
  %71 = call i8* @malloc(i32 16)
  %72 = bitcast i8* %71 to %literal*
  %73 = getelementptr inbounds %literal, %literal* %72, i32 0, i32 0
  %74 = getelementptr inbounds %literal, %literal* %72, i32 0, i32 1
  store double 1.000000e+00, double* %73
  store double %70, double* %74
  br label %add.end8

add.str7:                                         ; preds = %add.cstr24
  %75 = bitcast %literal* %50 to %string_literal*
  %76 = bitcast %literal* %53 to %string_literal*
  %77 = getelementptr inbounds %string_literal, %string_literal* %75, i32 0, i32 1
  %78 = getelementptr inbounds %string_literal, %string_literal* %76, i32 0, i32 1
  %79 = load i8*, i8** %77
  %80 = load i8*, i8** %78
  %81 = call i8* @strconcat(i8* %79, i8* %80)
  %82 = call i8* @malloc(i32 16)
  %83 = bitcast i8* %82 to %string_literal*
  %84 = getelementptr inbounds %string_literal, %string_literal* %83, i32 0, i32 0
  %85 = getelementptr inbounds %string_literal, %string_literal* %83, i32 0, i32 1
  store double 3.000000e+00, double* %84
  store i8* %81, i8** %85
  %86 = bitcast %string_literal* %83 to %literal*
  br label %add.end8

add.end8:                                         ; preds = %add.str7, %add.num6
  %87 = phi %literal* [ %72, %add.num6 ], [ %86, %add.str7 ]
  %88 = getelementptr inbounds %literal*, %literal** %7, i32 2
  store %literal* %87, %literal** %88
  %89 = call i8* @malloc(i32 16)
  %90 = bitcast i8* %89 to %literal*
  %91 = getelementptr inbounds %literal, %literal* %90, i32 0, i32 0
  %92 = getelementptr inbounds %literal, %literal* %90, i32 0, i32 1
  store double 1.000000e+00, double* %91
  store double 1.000000e+02, double* %92
  %93 = getelementptr inbounds %literal, %literal* %87, i32 0, i32 1
  %94 = getelementptr inbounds %literal, %literal* %90, i32 0, i32 1
  %95 = load double, double* %93
  %96 = load double, double* %94
  %97 = getelementptr inbounds %literal, %literal* %87, i32 0, i32 0
  %98 = getelementptr inbounds %literal, %literal* %90, i32 0, i32 0
  %99 = load double, double* %97
  %100 = load double, double* %98
  %101 = fcmp oeq double %99, 1.000000e+00
  br i1 %101, label %add.num19, label %add.cstr110

add.num19:                                        ; preds = %add.end8
  %102 = fcmp oeq double %100, 1.000000e+00
  br i1 %102, label %add.num13, label %add.err12

add.cstr110:                                      ; preds = %add.end8
  %103 = fcmp oeq double %99, 3.000000e+00
  br i1 %103, label %add.cstr211, label %add.err12

add.cstr211:                                      ; preds = %add.cstr110
  %104 = fcmp oeq double %100, 3.000000e+00
  br i1 %104, label %add.str14, label %add.err12

add.err12:                                        ; preds = %add.cstr211, %add.cstr110, %add.num19
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @2, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num13

add.num13:                                        ; preds = %add.err12, %add.num19
  %105 = load double, double* %93
  %106 = load double, double* %94
  %107 = fadd double %105, %106
  %108 = call i8* @malloc(i32 16)
  %109 = bitcast i8* %108 to %literal*
  %110 = getelementptr inbounds %literal, %literal* %109, i32 0, i32 0
  %111 = getelementptr inbounds %literal, %literal* %109, i32 0, i32 1
  store double 1.000000e+00, double* %110
  store double %107, double* %111
  br label %add.end15

add.str14:                                        ; preds = %add.cstr211
  %112 = bitcast %literal* %87 to %string_literal*
  %113 = bitcast %literal* %90 to %string_literal*
  %114 = getelementptr inbounds %string_literal, %string_literal* %112, i32 0, i32 1
  %115 = getelementptr inbounds %string_literal, %string_literal* %113, i32 0, i32 1
  %116 = load i8*, i8** %114
  %117 = load i8*, i8** %115
  %118 = call i8* @strconcat(i8* %116, i8* %117)
  %119 = call i8* @malloc(i32 16)
  %120 = bitcast i8* %119 to %string_literal*
  %121 = getelementptr inbounds %string_literal, %string_literal* %120, i32 0, i32 0
  %122 = getelementptr inbounds %string_literal, %string_literal* %120, i32 0, i32 1
  store double 3.000000e+00, double* %121
  store i8* %118, i8** %122
  %123 = bitcast %string_literal* %120 to %literal*
  br label %add.end15

add.end15:                                        ; preds = %add.str14, %add.num13
  %124 = phi %literal* [ %109, %add.num13 ], [ %123, %add.str14 ]
  ret %literal* %124
}

