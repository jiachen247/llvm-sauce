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
@4 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@5 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1

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
  %env1 = call i8* @malloc(i32 40)
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
  %12 = getelementptr inbounds %literal*, %literal** %5, i32 2
  store volatile %literal* %8, %literal** %12
  %13 = getelementptr inbounds %literal*, %literal** %5, i32 3
  store volatile %literal* %8, %literal** %13
  %14 = getelementptr inbounds %literal*, %literal** %5, i32 4
  store volatile %literal* %8, %literal** %14
  %15 = call i8* @malloc(i32 16)
  %16 = bitcast i8* %15 to %function_literal*
  %17 = getelementptr inbounds %function_literal, %function_literal* %16, i32 0, i32 0
  %18 = getelementptr inbounds %function_literal, %function_literal* %16, i32 0, i32 1
  %19 = getelementptr inbounds %function_literal, %function_literal* %16, i32 0, i32 2
  store double 4.000000e+00, double* %17
  store %literal** %5, %literal*** %18
  store %literal* (%literal**, %literal**)* @__compose, %literal* (%literal**, %literal**)** %19
  %20 = bitcast %function_literal* %16 to %literal*
  %21 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %20, %literal** %21
  %22 = call i8* @malloc(i32 16)
  %23 = bitcast i8* %22 to %function_literal*
  %24 = getelementptr inbounds %function_literal, %function_literal* %23, i32 0, i32 0
  %25 = getelementptr inbounds %function_literal, %function_literal* %23, i32 0, i32 1
  %26 = getelementptr inbounds %function_literal, %function_literal* %23, i32 0, i32 2
  store double 4.000000e+00, double* %24
  store %literal** %5, %literal*** %25
  store %literal* (%literal**, %literal**)* @__add, %literal* (%literal**, %literal**)** %26
  %27 = bitcast %function_literal* %23 to %literal*
  %28 = getelementptr inbounds %literal*, %literal** %5, i32 2
  store %literal* %27, %literal** %28
  %29 = call i8* @malloc(i32 16)
  %30 = bitcast i8* %29 to %function_literal*
  %31 = getelementptr inbounds %function_literal, %function_literal* %30, i32 0, i32 0
  %32 = getelementptr inbounds %function_literal, %function_literal* %30, i32 0, i32 1
  %33 = getelementptr inbounds %function_literal, %function_literal* %30, i32 0, i32 2
  store double 4.000000e+00, double* %31
  store %literal** %5, %literal*** %32
  store %literal* (%literal**, %literal**)* @__mul, %literal* (%literal**, %literal**)** %33
  %34 = bitcast %function_literal* %30 to %literal*
  %35 = getelementptr inbounds %literal*, %literal** %5, i32 3
  store %literal* %34, %literal** %35
  %36 = getelementptr inbounds %literal*, %literal** %5, i32 2
  %37 = load %literal*, %literal** %36
  %38 = getelementptr inbounds %literal*, %literal** %5, i32 3
  %39 = load %literal*, %literal** %38
  %40 = getelementptr inbounds %literal*, %literal** %5, i32 1
  %41 = load %literal*, %literal** %40
  %42 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 0
  %43 = load double, double* %42
  %44 = fcmp oeq double %43, 4.000000e+00
  br i1 %44, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @4, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %entry
  %45 = bitcast %literal* %41 to %function_literal*
  %46 = getelementptr inbounds %function_literal, %function_literal* %45, i32 0, i32 2
  %47 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %46
  %48 = getelementptr inbounds %function_literal, %function_literal* %45, i32 0, i32 1
  %49 = load %literal**, %literal*** %48
  %params = call i8* @malloc(i32 16)
  %50 = bitcast i8* %params to %literal**
  %51 = getelementptr inbounds %literal*, %literal** %50, i32 0
  store %literal* %37, %literal** %51
  %52 = getelementptr inbounds %literal*, %literal** %50, i32 1
  store %literal* %39, %literal** %52
  %53 = call %literal* %47(%literal** %49, %literal** %50)
  %54 = getelementptr inbounds %literal*, %literal** %5, i32 4
  store %literal* %53, %literal** %54
  %55 = call i8* @malloc(i32 16)
  %56 = bitcast i8* %55 to %literal*
  %57 = getelementptr inbounds %literal, %literal* %56, i32 0, i32 0
  %58 = getelementptr inbounds %literal, %literal* %56, i32 0, i32 1
  store double 1.000000e+00, double* %57
  store double 5.000000e+00, double* %58
  %59 = getelementptr inbounds %literal*, %literal** %5, i32 4
  %60 = load %literal*, %literal** %59
  %61 = getelementptr inbounds %literal, %literal* %60, i32 0, i32 0
  %62 = load double, double* %61
  %63 = fcmp oeq double %62, 4.000000e+00
  br i1 %63, label %next3, label %error2

error2:                                           ; preds = %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @5, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next3

next3:                                            ; preds = %error2, %next
  %64 = bitcast %literal* %60 to %function_literal*
  %65 = getelementptr inbounds %function_literal, %function_literal* %64, i32 0, i32 2
  %66 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %65
  %67 = getelementptr inbounds %function_literal, %function_literal* %64, i32 0, i32 1
  %68 = load %literal**, %literal*** %67
  %params4 = call i8* @malloc(i32 8)
  %69 = bitcast i8* %params4 to %literal**
  %70 = getelementptr inbounds %literal*, %literal** %69, i32 0
  store %literal* %56, %literal** %70
  %71 = call %literal* %66(%literal** %68, %literal** %69)
  call void @display(%literal* %71)
  ret i32 0
}

define %literal* @__compose(%literal** %0, %literal** %1) {
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
  %env1 = call i8* @malloc(i32 16)
  %10 = bitcast i8* %env1 to %literal**
  %11 = bitcast %literal** %10 to %literal***
  store %literal** %2, %literal*** %11
  %12 = call i8* @malloc(i32 16)
  %13 = bitcast i8* %12 to %literal*
  %14 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 0
  %15 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 1
  store double 5.000000e+00, double* %14
  store double 0.000000e+00, double* %15
  %16 = getelementptr inbounds %literal*, %literal** %10, i32 1
  store volatile %literal* %13, %literal** %16
  %17 = call i8* @malloc(i32 16)
  %18 = bitcast i8* %17 to %function_literal*
  %19 = getelementptr inbounds %function_literal, %function_literal* %18, i32 0, i32 0
  %20 = getelementptr inbounds %function_literal, %function_literal* %18, i32 0, i32 1
  %21 = getelementptr inbounds %function_literal, %function_literal* %18, i32 0, i32 2
  store double 4.000000e+00, double* %19
  store %literal** %10, %literal*** %20
  store %literal* (%literal**, %literal**)* @__a, %literal* (%literal**, %literal**)** %21
  %22 = bitcast %function_literal* %18 to %literal*
  %23 = getelementptr inbounds %literal*, %literal** %10, i32 1
  store %literal* %22, %literal** %23
  %24 = getelementptr inbounds %literal*, %literal** %10, i32 1
  %25 = load %literal*, %literal** %24
  ret %literal* %25
}

define %literal* @__a(%literal** %0, %literal** %1) {
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
  %env1 = call i8* @malloc(i32 8)
  %7 = bitcast i8* %env1 to %literal**
  %8 = bitcast %literal** %7 to %literal***
  store %literal** %2, %literal*** %8
  %9 = call i8* @malloc(i32 16)
  %10 = bitcast i8* %9 to %literal*
  %11 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 0
  %12 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 1
  store double 5.000000e+00, double* %11
  store double 0.000000e+00, double* %12
  %13 = bitcast %literal** %7 to %literal***
  %14 = load %literal**, %literal*** %13
  %15 = getelementptr inbounds %literal*, %literal** %14, i32 1
  %16 = load %literal*, %literal** %15
  %17 = bitcast %literal** %7 to %literal***
  %18 = load %literal**, %literal*** %17
  %19 = bitcast %literal** %18 to %literal***
  %20 = load %literal**, %literal*** %19
  %21 = bitcast %literal** %20 to %literal***
  %22 = load %literal**, %literal*** %21
  %23 = getelementptr inbounds %literal*, %literal** %22, i32 2
  %24 = load %literal*, %literal** %23
  %25 = getelementptr inbounds %literal, %literal* %24, i32 0, i32 0
  %26 = load double, double* %25
  %27 = fcmp oeq double %26, 4.000000e+00
  br i1 %27, label %next, label %error

error:                                            ; preds = %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %f.entry
  %28 = bitcast %literal* %24 to %function_literal*
  %29 = getelementptr inbounds %function_literal, %function_literal* %28, i32 0, i32 2
  %30 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %29
  %31 = getelementptr inbounds %function_literal, %function_literal* %28, i32 0, i32 1
  %32 = load %literal**, %literal*** %31
  %params = call i8* @malloc(i32 8)
  %33 = bitcast i8* %params to %literal**
  %34 = getelementptr inbounds %literal*, %literal** %33, i32 0
  store %literal* %16, %literal** %34
  %35 = call %literal* %30(%literal** %32, %literal** %33)
  %36 = bitcast %literal** %7 to %literal***
  %37 = load %literal**, %literal*** %36
  %38 = bitcast %literal** %37 to %literal***
  %39 = load %literal**, %literal*** %38
  %40 = bitcast %literal** %39 to %literal***
  %41 = load %literal**, %literal*** %40
  %42 = getelementptr inbounds %literal*, %literal** %41, i32 1
  %43 = load %literal*, %literal** %42
  %44 = getelementptr inbounds %literal, %literal* %43, i32 0, i32 0
  %45 = load double, double* %44
  %46 = fcmp oeq double %45, 4.000000e+00
  br i1 %46, label %next3, label %error2

error2:                                           ; preds = %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next3

next3:                                            ; preds = %error2, %next
  %47 = bitcast %literal* %43 to %function_literal*
  %48 = getelementptr inbounds %function_literal, %function_literal* %47, i32 0, i32 2
  %49 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %48
  %50 = getelementptr inbounds %function_literal, %function_literal* %47, i32 0, i32 1
  %51 = load %literal**, %literal*** %50
  %params4 = call i8* @malloc(i32 8)
  %52 = bitcast i8* %params4 to %literal**
  %53 = getelementptr inbounds %literal*, %literal** %52, i32 0
  store %literal* %35, %literal** %53
  %54 = call %literal* %49(%literal** %51, %literal** %52)
  ret %literal* %54
}

define %literal* @__add(%literal** %0, %literal** %1) {
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
  %env1 = call i8* @malloc(i32 8)
  %7 = bitcast i8* %env1 to %literal**
  %8 = bitcast %literal** %7 to %literal***
  store %literal** %2, %literal*** %8
  %9 = call i8* @malloc(i32 16)
  %10 = bitcast i8* %9 to %literal*
  %11 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 0
  %12 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 1
  store double 5.000000e+00, double* %11
  store double 0.000000e+00, double* %12
  %13 = bitcast %literal** %7 to %literal***
  %14 = load %literal**, %literal*** %13
  %15 = getelementptr inbounds %literal*, %literal** %14, i32 1
  %16 = load %literal*, %literal** %15
  %17 = call i8* @malloc(i32 16)
  %18 = bitcast i8* %17 to %literal*
  %19 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 0
  %20 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 1
  store double 1.000000e+00, double* %19
  store double 1.000000e+00, double* %20
  %21 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 1
  %22 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 1
  %23 = load double, double* %21
  %24 = load double, double* %22
  %25 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 0
  %26 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 0
  %27 = load double, double* %25
  %28 = load double, double* %26
  %29 = fcmp oeq double %27, 1.000000e+00
  br i1 %29, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %f.entry
  %30 = fcmp oeq double %28, 1.000000e+00
  br i1 %30, label %add.num, label %add.err

add.cstr1:                                        ; preds = %f.entry
  %31 = fcmp oeq double %27, 3.000000e+00
  br i1 %31, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %32 = fcmp oeq double %28, 3.000000e+00
  br i1 %32, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @2, i32 0, i32 0))
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
  %40 = bitcast %literal* %16 to %string_literal*
  %41 = bitcast %literal* %18 to %string_literal*
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
  ret %literal* %52
}

define %literal* @__mul(%literal** %0, %literal** %1) {
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
  %env1 = call i8* @malloc(i32 8)
  %7 = bitcast i8* %env1 to %literal**
  %8 = bitcast %literal** %7 to %literal***
  store %literal** %2, %literal*** %8
  %9 = call i8* @malloc(i32 16)
  %10 = bitcast i8* %9 to %literal*
  %11 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 0
  %12 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 1
  store double 5.000000e+00, double* %11
  store double 0.000000e+00, double* %12
  %13 = bitcast %literal** %7 to %literal***
  %14 = load %literal**, %literal*** %13
  %15 = getelementptr inbounds %literal*, %literal** %14, i32 1
  %16 = load %literal*, %literal** %15
  %17 = call i8* @malloc(i32 16)
  %18 = bitcast i8* %17 to %literal*
  %19 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 0
  %20 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 1
  store double 1.000000e+00, double* %19
  store double 2.000000e+00, double* %20
  %21 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 1
  %22 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 1
  %23 = load double, double* %21
  %24 = load double, double* %22
  %25 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 0
  %26 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 0
  %27 = load double, double* %25
  %28 = load double, double* %26
  %29 = fcmp oeq double %27, 1.000000e+00
  br i1 %29, label %tc.next, label %tc.error

tc.next:                                          ; preds = %f.entry
  %30 = fcmp oeq double %28, 1.000000e+00
  br i1 %30, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @3, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %31 = fmul double %23, %24
  %32 = call i8* @malloc(i32 16)
  %33 = bitcast i8* %32 to %literal*
  %34 = getelementptr inbounds %literal, %literal* %33, i32 0, i32 0
  %35 = getelementptr inbounds %literal, %literal* %33, i32 0, i32 1
  store double 1.000000e+00, double* %34
  store double %31, double* %35
  ret %literal* %33
}

