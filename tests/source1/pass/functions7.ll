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
  store %literal* %8, %literal** %11
  %12 = getelementptr inbounds %literal*, %literal** %5, i32 2
  store %literal* %8, %literal** %12
  %13 = getelementptr inbounds %literal*, %literal** %5, i32 3
  store %literal* %8, %literal** %13
  %14 = getelementptr inbounds %literal*, %literal** %5, i32 4
  store %literal* %8, %literal** %14
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
  %36 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %37 = load double, double* %36
  %38 = fcmp oeq double %37, 4.000000e+00
  br i1 %38, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %entry
  %39 = bitcast %literal* %20 to %function_literal*
  %40 = getelementptr inbounds %function_literal, %function_literal* %39, i32 0, i32 2
  %41 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %40
  %42 = getelementptr inbounds %function_literal, %function_literal* %39, i32 0, i32 1
  %43 = load %literal**, %literal*** %42
  %params = call i8* @malloc(i32 16)
  %44 = bitcast i8* %params to %literal**
  %45 = getelementptr inbounds %literal*, %literal** %44, i32 0
  store %literal* %27, %literal** %45
  %46 = getelementptr inbounds %literal*, %literal** %44, i32 1
  store %literal* %34, %literal** %46
  %47 = call %literal* %41(%literal** %43, %literal** %44)
  %48 = getelementptr inbounds %literal*, %literal** %5, i32 4
  store %literal* %47, %literal** %48
  %49 = call i8* @malloc(i32 16)
  %50 = bitcast i8* %49 to %literal*
  %51 = getelementptr inbounds %literal, %literal* %50, i32 0, i32 0
  %52 = getelementptr inbounds %literal, %literal* %50, i32 0, i32 1
  store double 1.000000e+00, double* %51
  store double 5.000000e+00, double* %52
  %53 = getelementptr inbounds %literal, %literal* %47, i32 0, i32 0
  %54 = load double, double* %53
  %55 = fcmp oeq double %54, 4.000000e+00
  br i1 %55, label %next3, label %error2

error2:                                           ; preds = %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next3

next3:                                            ; preds = %error2, %next
  %56 = bitcast %literal* %47 to %function_literal*
  %57 = getelementptr inbounds %function_literal, %function_literal* %56, i32 0, i32 2
  %58 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %57
  %59 = getelementptr inbounds %function_literal, %function_literal* %56, i32 0, i32 1
  %60 = load %literal**, %literal*** %59
  %params4 = call i8* @malloc(i32 8)
  %61 = bitcast i8* %params4 to %literal**
  %62 = getelementptr inbounds %literal*, %literal** %61, i32 0
  store %literal* %50, %literal** %62
  %63 = call %literal* %58(%literal** %60, %literal** %61)
  call void @display(%literal* %63)
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
  store %literal* %13, %literal** %16
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
  ret %literal* %22
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
  %13 = bitcast %literal** %2 to %literal***
  %14 = load %literal**, %literal*** %13
  %15 = bitcast %literal** %14 to %literal***
  %16 = load %literal**, %literal*** %15
  %17 = getelementptr inbounds %literal*, %literal** %16, i32 2
  %18 = load %literal*, %literal** %17
  %19 = getelementptr inbounds %literal, %literal* %18, i32 0, i32 0
  %20 = load double, double* %19
  %21 = fcmp oeq double %20, 4.000000e+00
  br i1 %21, label %next, label %error

error:                                            ; preds = %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %f.entry
  %22 = bitcast %literal* %18 to %function_literal*
  %23 = getelementptr inbounds %function_literal, %function_literal* %22, i32 0, i32 2
  %24 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %23
  %25 = getelementptr inbounds %function_literal, %function_literal* %22, i32 0, i32 1
  %26 = load %literal**, %literal*** %25
  %params = call i8* @malloc(i32 8)
  %27 = bitcast i8* %params to %literal**
  %28 = getelementptr inbounds %literal*, %literal** %27, i32 0
  store %literal* %5, %literal** %28
  %29 = call %literal* %24(%literal** %26, %literal** %27)
  %30 = bitcast %literal** %2 to %literal***
  %31 = load %literal**, %literal*** %30
  %32 = bitcast %literal** %31 to %literal***
  %33 = load %literal**, %literal*** %32
  %34 = getelementptr inbounds %literal*, %literal** %33, i32 1
  %35 = load %literal*, %literal** %34
  %36 = getelementptr inbounds %literal, %literal* %35, i32 0, i32 0
  %37 = load double, double* %36
  %38 = fcmp oeq double %37, 4.000000e+00
  br i1 %38, label %next3, label %error2

error2:                                           ; preds = %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next3

next3:                                            ; preds = %error2, %next
  %39 = bitcast %literal* %35 to %function_literal*
  %40 = getelementptr inbounds %function_literal, %function_literal* %39, i32 0, i32 2
  %41 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %40
  %42 = getelementptr inbounds %function_literal, %function_literal* %39, i32 0, i32 1
  %43 = load %literal**, %literal*** %42
  %params4 = call i8* @malloc(i32 8)
  %44 = bitcast i8* %params4 to %literal**
  %45 = getelementptr inbounds %literal*, %literal** %44, i32 0
  store %literal* %29, %literal** %45
  %46 = call %literal* %41(%literal** %43, %literal** %44)
  ret %literal* %46
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
  %13 = call i8* @malloc(i32 16)
  %14 = bitcast i8* %13 to %literal*
  %15 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 0
  %16 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 1
  store double 1.000000e+00, double* %15
  store double 1.000000e+00, double* %16
  %17 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %18 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 1
  %19 = load double, double* %17
  %20 = load double, double* %18
  %21 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 0
  %23 = load double, double* %21
  %24 = load double, double* %22
  %25 = fcmp oeq double %23, 1.000000e+00
  br i1 %25, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %f.entry
  %26 = fcmp oeq double %24, 1.000000e+00
  br i1 %26, label %add.num, label %add.err

add.cstr1:                                        ; preds = %f.entry
  %27 = fcmp oeq double %23, 3.000000e+00
  br i1 %27, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %28 = fcmp oeq double %24, 3.000000e+00
  br i1 %28, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %29 = load double, double* %17
  %30 = load double, double* %18
  %31 = fadd double %29, %30
  %32 = call i8* @malloc(i32 16)
  %33 = bitcast i8* %32 to %literal*
  %34 = getelementptr inbounds %literal, %literal* %33, i32 0, i32 0
  %35 = getelementptr inbounds %literal, %literal* %33, i32 0, i32 1
  store double 1.000000e+00, double* %34
  store double %31, double* %35
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %36 = bitcast %literal* %5 to %string_literal*
  %37 = bitcast %literal* %14 to %string_literal*
  %38 = getelementptr inbounds %string_literal, %string_literal* %36, i32 0, i32 1
  %39 = getelementptr inbounds %string_literal, %string_literal* %37, i32 0, i32 1
  %40 = load i8*, i8** %38
  %41 = load i8*, i8** %39
  %42 = call i8* @strconcat(i8* %40, i8* %41)
  %43 = call i8* @malloc(i32 16)
  %44 = bitcast i8* %43 to %string_literal*
  %45 = getelementptr inbounds %string_literal, %string_literal* %44, i32 0, i32 0
  %46 = getelementptr inbounds %string_literal, %string_literal* %44, i32 0, i32 1
  store double 3.000000e+00, double* %45
  store i8* %42, i8** %46
  %47 = bitcast %string_literal* %44 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %48 = phi %literal* [ %33, %add.num ], [ %47, %add.str ]
  ret %literal* %48
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
  %13 = call i8* @malloc(i32 16)
  %14 = bitcast i8* %13 to %literal*
  %15 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 0
  %16 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 1
  store double 1.000000e+00, double* %15
  store double 2.000000e+00, double* %16
  %17 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %18 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 1
  %19 = load double, double* %17
  %20 = load double, double* %18
  %21 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 0
  %23 = load double, double* %21
  %24 = load double, double* %22
  %25 = fcmp oeq double %23, 1.000000e+00
  br i1 %25, label %tc.next, label %tc.error

tc.next:                                          ; preds = %f.entry
  %26 = fcmp oeq double %24, 1.000000e+00
  br i1 %26, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %27 = fmul double %19, %20
  %28 = call i8* @malloc(i32 16)
  %29 = bitcast i8* %28 to %literal*
  %30 = getelementptr inbounds %literal, %literal* %29, i32 0, i32 0
  %31 = getelementptr inbounds %literal, %literal* %29, i32 0, i32 1
  store double 1.000000e+00, double* %30
  store double %27, double* %31
  ret %literal* %29
}

