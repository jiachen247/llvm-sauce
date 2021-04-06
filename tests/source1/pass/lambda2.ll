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
  store double 1.000000e+02, double* %22
  %23 = getelementptr inbounds %literal, %literal* %17, i32 0, i32 0
  %24 = load double, double* %23
  %25 = fcmp oeq double %24, 4.000000e+00
  br i1 %25, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
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
  %7 = call i8* @malloc(i32 16)
  %8 = bitcast i8* %7 to %literal*
  %9 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %10 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  store double 1.000000e+00, double* %9
  store double 1.000000e+00, double* %10
  %11 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %12 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  %13 = load double, double* %11
  %14 = load double, double* %12
  %15 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %16 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %17 = load double, double* %15
  %18 = load double, double* %16
  %19 = fcmp oeq double %17, 1.000000e+00
  br i1 %19, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %f.entry
  %20 = fcmp oeq double %18, 1.000000e+00
  br i1 %20, label %add.num, label %add.err

add.cstr1:                                        ; preds = %f.entry
  %21 = fcmp oeq double %17, 3.000000e+00
  br i1 %21, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %22 = fcmp oeq double %18, 3.000000e+00
  br i1 %22, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %23 = load double, double* %11
  %24 = load double, double* %12
  %25 = fadd double %23, %24
  %26 = call i8* @malloc(i32 16)
  %27 = bitcast i8* %26 to %literal*
  %28 = getelementptr inbounds %literal, %literal* %27, i32 0, i32 0
  %29 = getelementptr inbounds %literal, %literal* %27, i32 0, i32 1
  store double 1.000000e+00, double* %28
  store double %25, double* %29
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %30 = bitcast %literal* %5 to %string_literal*
  %31 = bitcast %literal* %8 to %string_literal*
  %32 = getelementptr inbounds %string_literal, %string_literal* %30, i32 0, i32 1
  %33 = getelementptr inbounds %string_literal, %string_literal* %31, i32 0, i32 1
  %34 = load i8*, i8** %32
  %35 = load i8*, i8** %33
  %36 = call i8* @strconcat(i8* %34, i8* %35)
  %37 = call i8* @malloc(i32 16)
  %38 = bitcast i8* %37 to %string_literal*
  %39 = getelementptr inbounds %string_literal, %string_literal* %38, i32 0, i32 0
  %40 = getelementptr inbounds %string_literal, %string_literal* %38, i32 0, i32 1
  store double 3.000000e+00, double* %39
  store i8* %36, i8** %40
  %41 = bitcast %string_literal* %38 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %42 = phi %literal* [ %27, %add.num ], [ %41, %add.str ]
  ret %literal* %42
}

