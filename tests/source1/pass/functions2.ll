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
  %27 = getelementptr inbounds %literal*, %literal** %5, i32 1
  %28 = load %literal*, %literal** %27
  %29 = getelementptr inbounds %literal, %literal* %28, i32 0, i32 0
  %30 = load double, double* %29
  %31 = fcmp oeq double %30, 4.000000e+00
  br i1 %31, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %entry
  %32 = bitcast %literal* %28 to %function_literal*
  %33 = getelementptr inbounds %function_literal, %function_literal* %32, i32 0, i32 2
  %34 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %33
  %35 = getelementptr inbounds %function_literal, %function_literal* %32, i32 0, i32 1
  %36 = load %literal**, %literal*** %35
  %params = call i8* @malloc(i32 16)
  %37 = bitcast i8* %params to %literal**
  %38 = getelementptr inbounds %literal*, %literal** %37, i32 0
  store %literal* %20, %literal** %38
  %39 = getelementptr inbounds %literal*, %literal** %37, i32 1
  store %literal* %24, %literal** %39
  %40 = call %literal* %34(%literal** %36, %literal** %37)
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
  %16 = bitcast %literal** %10 to %literal***
  %17 = load %literal**, %literal*** %16
  %18 = getelementptr inbounds %literal*, %literal** %17, i32 1
  %19 = load %literal*, %literal** %18
  %20 = bitcast %literal** %10 to %literal***
  %21 = load %literal**, %literal*** %20
  %22 = getelementptr inbounds %literal*, %literal** %21, i32 2
  %23 = load %literal*, %literal** %22
  %24 = getelementptr inbounds %literal, %literal* %19, i32 0, i32 1
  %25 = getelementptr inbounds %literal, %literal* %23, i32 0, i32 1
  %26 = load double, double* %24
  %27 = load double, double* %25
  %28 = getelementptr inbounds %literal, %literal* %19, i32 0, i32 0
  %29 = getelementptr inbounds %literal, %literal* %23, i32 0, i32 0
  %30 = load double, double* %28
  %31 = load double, double* %29
  %32 = fcmp oeq double %30, 1.000000e+00
  br i1 %32, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %f.entry
  %33 = fcmp oeq double %31, 1.000000e+00
  br i1 %33, label %add.num, label %add.err

add.cstr1:                                        ; preds = %f.entry
  %34 = fcmp oeq double %30, 3.000000e+00
  br i1 %34, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %35 = fcmp oeq double %31, 3.000000e+00
  br i1 %35, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %36 = load double, double* %24
  %37 = load double, double* %25
  %38 = fadd double %36, %37
  %39 = call i8* @malloc(i32 16)
  %40 = bitcast i8* %39 to %literal*
  %41 = getelementptr inbounds %literal, %literal* %40, i32 0, i32 0
  %42 = getelementptr inbounds %literal, %literal* %40, i32 0, i32 1
  store double 1.000000e+00, double* %41
  store double %38, double* %42
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %43 = bitcast %literal* %19 to %string_literal*
  %44 = bitcast %literal* %23 to %string_literal*
  %45 = getelementptr inbounds %string_literal, %string_literal* %43, i32 0, i32 1
  %46 = getelementptr inbounds %string_literal, %string_literal* %44, i32 0, i32 1
  %47 = load i8*, i8** %45
  %48 = load i8*, i8** %46
  %49 = call i8* @strconcat(i8* %47, i8* %48)
  %50 = call i8* @malloc(i32 16)
  %51 = bitcast i8* %50 to %string_literal*
  %52 = getelementptr inbounds %string_literal, %string_literal* %51, i32 0, i32 0
  %53 = getelementptr inbounds %string_literal, %string_literal* %51, i32 0, i32 1
  store double 3.000000e+00, double* %52
  store i8* %49, i8** %53
  %54 = bitcast %string_literal* %51 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %55 = phi %literal* [ %40, %add.num ], [ %54, %add.str ]
  call void @display(%literal* %55)
  ret %literal* %13
}

