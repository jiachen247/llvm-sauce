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
  store %literal* (%literal**, %literal**)* @__f, %literal* (%literal**, %literal**)** %16
  %17 = bitcast %function_literal* %13 to %literal*
  %18 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %17, %literal** %18
  %19 = call i8* @malloc(i32 16)
  %20 = bitcast i8* %19 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  store double 1.000000e+00, double* %21
  store double 1.000000e+02, double* %22
  %23 = call i8* @malloc(i32 16)
  %24 = bitcast i8* %23 to %literal*
  %25 = getelementptr inbounds %literal, %literal* %24, i32 0, i32 0
  %26 = getelementptr inbounds %literal, %literal* %24, i32 0, i32 1
  store double 1.000000e+00, double* %25
  store double 2.000000e+02, double* %26
  %27 = getelementptr inbounds %literal, %literal* %17, i32 0, i32 0
  %28 = load double, double* %27
  %29 = fcmp oeq double %28, 4.000000e+00
  br i1 %29, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @3, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %entry
  %30 = bitcast %literal* %17 to %function_literal*
  %31 = getelementptr inbounds %function_literal, %function_literal* %30, i32 0, i32 2
  %32 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %31
  %33 = getelementptr inbounds %function_literal, %function_literal* %30, i32 0, i32 1
  %34 = load %literal**, %literal*** %33
  %params = call i8* @malloc(i32 16)
  %35 = bitcast i8* %params to %literal**
  %36 = getelementptr inbounds %literal*, %literal** %35, i32 0
  store %literal* %20, %literal** %36
  %37 = getelementptr inbounds %literal*, %literal** %35, i32 1
  store %literal* %24, %literal** %37
  %38 = call %literal* %32(%literal** %34, %literal** %35)
  call void @display(%literal* %38)
  ret i32 0
}

define %literal* @__f(%literal** %0, %literal** %1) {
f.setup:
  %env = call i8* @malloc(i32 24)
  %2 = bitcast i8* %env to %literal**
  %3 = bitcast %literal** %2 to %literal***
  store %literal** %0, %literal*** %3
  %4 = getelementptr inbounds %literal*, %literal** %1, i32 0
  %5 = load %literal*, %literal** %4
  %6 = getelementptr inbounds %literal*, %literal** %2, i32 1
  store %literal* %5, %literal** %6
  %7 = getelementptr inbounds %literal*, %literal** %1, i32 1
  %8 = load %literal*, %literal** %7
  %9 = getelementptr inbounds %literal*, %literal** %2, i32 2
  store %literal* %8, %literal** %9
  br label %f.entry

f.entry:                                          ; preds = %f.setup
  %env1 = call i8* @malloc(i32 8)
  %10 = bitcast i8* %env1 to %literal**
  %11 = bitcast %literal** %10 to %literal***
  store %literal** %2, %literal*** %11
  %12 = call i8* @malloc(i32 16)
  %13 = bitcast i8* %12 to %literal*
  %14 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 0
  %15 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 1
  store double 5.000000e+00, double* %14
  store double 0.000000e+00, double* %15
  %16 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %17 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  %18 = load double, double* %16
  %19 = load double, double* %17
  %20 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %21 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %22 = load double, double* %20
  %23 = load double, double* %21
  %24 = fcmp oeq double %22, 1.000000e+00
  br i1 %24, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %f.entry
  %25 = fcmp oeq double %23, 1.000000e+00
  br i1 %25, label %add.num, label %add.err

add.cstr1:                                        ; preds = %f.entry
  %26 = fcmp oeq double %22, 3.000000e+00
  br i1 %26, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %27 = fcmp oeq double %23, 3.000000e+00
  br i1 %27, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %28 = load double, double* %16
  %29 = load double, double* %17
  %30 = fadd double %28, %29
  %31 = call i8* @malloc(i32 16)
  %32 = bitcast i8* %31 to %literal*
  %33 = getelementptr inbounds %literal, %literal* %32, i32 0, i32 0
  %34 = getelementptr inbounds %literal, %literal* %32, i32 0, i32 1
  store double 1.000000e+00, double* %33
  store double %30, double* %34
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %35 = bitcast %literal* %5 to %string_literal*
  %36 = bitcast %literal* %8 to %string_literal*
  %37 = getelementptr inbounds %string_literal, %string_literal* %35, i32 0, i32 1
  %38 = getelementptr inbounds %string_literal, %string_literal* %36, i32 0, i32 1
  %39 = load i8*, i8** %37
  %40 = load i8*, i8** %38
  %41 = call i8* @strconcat(i8* %39, i8* %40)
  %42 = call i8* @malloc(i32 16)
  %43 = bitcast i8* %42 to %string_literal*
  %44 = getelementptr inbounds %string_literal, %string_literal* %43, i32 0, i32 0
  %45 = getelementptr inbounds %string_literal, %string_literal* %43, i32 0, i32 1
  store double 3.000000e+00, double* %44
  store i8* %41, i8** %45
  %46 = bitcast %string_literal* %43 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %47 = phi %literal* [ %32, %add.num ], [ %46, %add.str ]
  call void @display(%literal* %47)
  %48 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %49 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  %50 = load double, double* %48
  %51 = load double, double* %49
  %52 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %53 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %54 = load double, double* %52
  %55 = load double, double* %53
  %56 = fcmp oeq double %54, 1.000000e+00
  br i1 %56, label %add.num12, label %add.cstr13

add.num12:                                        ; preds = %add.end
  %57 = fcmp oeq double %55, 1.000000e+00
  br i1 %57, label %add.num6, label %add.err5

add.cstr13:                                       ; preds = %add.end
  %58 = fcmp oeq double %54, 3.000000e+00
  br i1 %58, label %add.cstr24, label %add.err5

add.cstr24:                                       ; preds = %add.cstr13
  %59 = fcmp oeq double %55, 3.000000e+00
  br i1 %59, label %add.str7, label %add.err5

add.err5:                                         ; preds = %add.cstr24, %add.cstr13, %add.num12
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num6

add.num6:                                         ; preds = %add.err5, %add.num12
  %60 = load double, double* %48
  %61 = load double, double* %49
  %62 = fadd double %60, %61
  %63 = call i8* @malloc(i32 16)
  %64 = bitcast i8* %63 to %literal*
  %65 = getelementptr inbounds %literal, %literal* %64, i32 0, i32 0
  %66 = getelementptr inbounds %literal, %literal* %64, i32 0, i32 1
  store double 1.000000e+00, double* %65
  store double %62, double* %66
  br label %add.end8

add.str7:                                         ; preds = %add.cstr24
  %67 = bitcast %literal* %5 to %string_literal*
  %68 = bitcast %literal* %8 to %string_literal*
  %69 = getelementptr inbounds %string_literal, %string_literal* %67, i32 0, i32 1
  %70 = getelementptr inbounds %string_literal, %string_literal* %68, i32 0, i32 1
  %71 = load i8*, i8** %69
  %72 = load i8*, i8** %70
  %73 = call i8* @strconcat(i8* %71, i8* %72)
  %74 = call i8* @malloc(i32 16)
  %75 = bitcast i8* %74 to %string_literal*
  %76 = getelementptr inbounds %string_literal, %string_literal* %75, i32 0, i32 0
  %77 = getelementptr inbounds %string_literal, %string_literal* %75, i32 0, i32 1
  store double 3.000000e+00, double* %76
  store i8* %73, i8** %77
  %78 = bitcast %string_literal* %75 to %literal*
  br label %add.end8

add.end8:                                         ; preds = %add.str7, %add.num6
  %79 = phi %literal* [ %64, %add.num6 ], [ %78, %add.str7 ]
  %80 = call i8* @malloc(i32 16)
  %81 = bitcast i8* %80 to %literal*
  %82 = getelementptr inbounds %literal, %literal* %81, i32 0, i32 0
  %83 = getelementptr inbounds %literal, %literal* %81, i32 0, i32 1
  store double 1.000000e+00, double* %82
  store double 1.000000e+00, double* %83
  %84 = getelementptr inbounds %literal, %literal* %79, i32 0, i32 1
  %85 = getelementptr inbounds %literal, %literal* %81, i32 0, i32 1
  %86 = load double, double* %84
  %87 = load double, double* %85
  %88 = getelementptr inbounds %literal, %literal* %79, i32 0, i32 0
  %89 = getelementptr inbounds %literal, %literal* %81, i32 0, i32 0
  %90 = load double, double* %88
  %91 = load double, double* %89
  %92 = fcmp oeq double %90, 1.000000e+00
  br i1 %92, label %add.num19, label %add.cstr110

add.num19:                                        ; preds = %add.end8
  %93 = fcmp oeq double %91, 1.000000e+00
  br i1 %93, label %add.num13, label %add.err12

add.cstr110:                                      ; preds = %add.end8
  %94 = fcmp oeq double %90, 3.000000e+00
  br i1 %94, label %add.cstr211, label %add.err12

add.cstr211:                                      ; preds = %add.cstr110
  %95 = fcmp oeq double %91, 3.000000e+00
  br i1 %95, label %add.str14, label %add.err12

add.err12:                                        ; preds = %add.cstr211, %add.cstr110, %add.num19
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @2, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num13

add.num13:                                        ; preds = %add.err12, %add.num19
  %96 = load double, double* %84
  %97 = load double, double* %85
  %98 = fadd double %96, %97
  %99 = call i8* @malloc(i32 16)
  %100 = bitcast i8* %99 to %literal*
  %101 = getelementptr inbounds %literal, %literal* %100, i32 0, i32 0
  %102 = getelementptr inbounds %literal, %literal* %100, i32 0, i32 1
  store double 1.000000e+00, double* %101
  store double %98, double* %102
  br label %add.end15

add.str14:                                        ; preds = %add.cstr211
  %103 = bitcast %literal* %79 to %string_literal*
  %104 = bitcast %literal* %81 to %string_literal*
  %105 = getelementptr inbounds %string_literal, %string_literal* %103, i32 0, i32 1
  %106 = getelementptr inbounds %string_literal, %string_literal* %104, i32 0, i32 1
  %107 = load i8*, i8** %105
  %108 = load i8*, i8** %106
  %109 = call i8* @strconcat(i8* %107, i8* %108)
  %110 = call i8* @malloc(i32 16)
  %111 = bitcast i8* %110 to %string_literal*
  %112 = getelementptr inbounds %string_literal, %string_literal* %111, i32 0, i32 0
  %113 = getelementptr inbounds %string_literal, %string_literal* %111, i32 0, i32 1
  store double 3.000000e+00, double* %112
  store i8* %109, i8** %113
  %114 = bitcast %string_literal* %111 to %literal*
  br label %add.end15

add.end15:                                        ; preds = %add.str14, %add.num13
  %115 = phi %literal* [ %100, %add.num13 ], [ %114, %add.str14 ]
  ret %literal* %115
}

