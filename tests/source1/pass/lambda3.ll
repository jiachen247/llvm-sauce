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
@6 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1

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
  store %literal* (%literal**, %literal**)* @__anon, %literal* (%literal**, %literal**)** %19
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
  store %literal* (%literal**, %literal**)* @__anon.1, %literal* (%literal**, %literal**)** %26
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
  store %literal* (%literal**, %literal**)* @__anon.2, %literal* (%literal**, %literal**)** %33
  %34 = bitcast %function_literal* %30 to %literal*
  %35 = getelementptr inbounds %literal*, %literal** %5, i32 3
  store %literal* %34, %literal** %35
  %36 = getelementptr inbounds %literal, %literal* %34, i32 0, i32 0
  %37 = load double, double* %36
  %38 = fcmp oeq double %37, 4.000000e+00
  br i1 %38, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @4, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %entry
  %39 = bitcast %literal* %34 to %function_literal*
  %40 = getelementptr inbounds %function_literal, %function_literal* %39, i32 0, i32 2
  %41 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %40
  %42 = getelementptr inbounds %function_literal, %function_literal* %39, i32 0, i32 1
  %43 = load %literal**, %literal*** %42
  %params = call i8* @malloc(i32 8)
  %44 = bitcast i8* %params to %literal**
  %45 = getelementptr inbounds %literal*, %literal** %44, i32 0
  store %literal* %20, %literal** %45
  %46 = call %literal* %41(%literal** %43, %literal** %44)
  %47 = getelementptr inbounds %literal, %literal* %46, i32 0, i32 0
  %48 = load double, double* %47
  %49 = fcmp oeq double %48, 4.000000e+00
  br i1 %49, label %next3, label %error2

error2:                                           ; preds = %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @5, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next3

next3:                                            ; preds = %error2, %next
  %50 = bitcast %literal* %46 to %function_literal*
  %51 = getelementptr inbounds %function_literal, %function_literal* %50, i32 0, i32 2
  %52 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %51
  %53 = getelementptr inbounds %function_literal, %function_literal* %50, i32 0, i32 1
  %54 = load %literal**, %literal*** %53
  %params4 = call i8* @malloc(i32 8)
  %55 = bitcast i8* %params4 to %literal**
  %56 = getelementptr inbounds %literal*, %literal** %55, i32 0
  store %literal* %27, %literal** %56
  %57 = call %literal* %52(%literal** %54, %literal** %55)
  %58 = getelementptr inbounds %literal*, %literal** %5, i32 4
  store %literal* %57, %literal** %58
  %59 = call i8* @malloc(i32 16)
  %60 = bitcast i8* %59 to %literal*
  %61 = getelementptr inbounds %literal, %literal* %60, i32 0, i32 0
  %62 = getelementptr inbounds %literal, %literal* %60, i32 0, i32 1
  store double 1.000000e+00, double* %61
  store double 2.000000e+02, double* %62
  %63 = getelementptr inbounds %literal, %literal* %57, i32 0, i32 0
  %64 = load double, double* %63
  %65 = fcmp oeq double %64, 4.000000e+00
  br i1 %65, label %next6, label %error5

error5:                                           ; preds = %next3
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @6, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next6

next6:                                            ; preds = %error5, %next3
  %66 = bitcast %literal* %57 to %function_literal*
  %67 = getelementptr inbounds %function_literal, %function_literal* %66, i32 0, i32 2
  %68 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %67
  %69 = getelementptr inbounds %function_literal, %function_literal* %66, i32 0, i32 1
  %70 = load %literal**, %literal*** %69
  %params7 = call i8* @malloc(i32 8)
  %71 = bitcast i8* %params7 to %literal**
  %72 = getelementptr inbounds %literal*, %literal** %71, i32 0
  store %literal* %60, %literal** %72
  %73 = call %literal* %68(%literal** %70, %literal** %71)
  call void @display(%literal* %73)
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

define %literal* @__anon.1(%literal** %0, %literal** %1) {
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
  store double 2.000000e+00, double* %10
  %11 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %12 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  %13 = load double, double* %11
  %14 = load double, double* %12
  %15 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %16 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %17 = load double, double* %15
  %18 = load double, double* %16
  %19 = fcmp oeq double %17, 1.000000e+00
  br i1 %19, label %tc.next, label %tc.error

tc.next:                                          ; preds = %f.entry
  %20 = fcmp oeq double %18, 1.000000e+00
  br i1 %20, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %21 = fmul double %13, %14
  %22 = call i8* @malloc(i32 16)
  %23 = bitcast i8* %22 to %literal*
  %24 = getelementptr inbounds %literal, %literal* %23, i32 0, i32 0
  %25 = getelementptr inbounds %literal, %literal* %23, i32 0, i32 1
  store double 1.000000e+00, double* %24
  store double %21, double* %25
  ret %literal* %23
}

define %literal* @__anon.2(%literal** %0, %literal** %1) {
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
  %8 = bitcast i8* %7 to %function_literal*
  %9 = getelementptr inbounds %function_literal, %function_literal* %8, i32 0, i32 0
  %10 = getelementptr inbounds %function_literal, %function_literal* %8, i32 0, i32 1
  %11 = getelementptr inbounds %function_literal, %function_literal* %8, i32 0, i32 2
  store double 4.000000e+00, double* %9
  store %literal** %2, %literal*** %10
  store %literal* (%literal**, %literal**)* @__anon.3, %literal* (%literal**, %literal**)** %11
  %12 = bitcast %function_literal* %8 to %literal*
  ret %literal* %12
}

define %literal* @__anon.3(%literal** %0, %literal** %1) {
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
  %8 = bitcast i8* %7 to %function_literal*
  %9 = getelementptr inbounds %function_literal, %function_literal* %8, i32 0, i32 0
  %10 = getelementptr inbounds %function_literal, %function_literal* %8, i32 0, i32 1
  %11 = getelementptr inbounds %function_literal, %function_literal* %8, i32 0, i32 2
  store double 4.000000e+00, double* %9
  store %literal** %2, %literal*** %10
  store %literal* (%literal**, %literal**)* @__anon.4, %literal* (%literal**, %literal**)** %11
  %12 = bitcast %function_literal* %8 to %literal*
  ret %literal* %12
}

define %literal* @__anon.4(%literal** %0, %literal** %1) {
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
  %7 = bitcast %literal** %2 to %literal***
  %8 = load %literal**, %literal*** %7
  %9 = getelementptr inbounds %literal*, %literal** %8, i32 1
  %10 = load %literal*, %literal** %9
  %11 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 0
  %12 = load double, double* %11
  %13 = fcmp oeq double %12, 4.000000e+00
  br i1 %13, label %next, label %error

error:                                            ; preds = %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @2, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %f.entry
  %14 = bitcast %literal* %10 to %function_literal*
  %15 = getelementptr inbounds %function_literal, %function_literal* %14, i32 0, i32 2
  %16 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %15
  %17 = getelementptr inbounds %function_literal, %function_literal* %14, i32 0, i32 1
  %18 = load %literal**, %literal*** %17
  %params = call i8* @malloc(i32 8)
  %19 = bitcast i8* %params to %literal**
  %20 = getelementptr inbounds %literal*, %literal** %19, i32 0
  store %literal* %5, %literal** %20
  %21 = call %literal* %16(%literal** %18, %literal** %19)
  %22 = bitcast %literal** %2 to %literal***
  %23 = load %literal**, %literal*** %22
  %24 = bitcast %literal** %23 to %literal***
  %25 = load %literal**, %literal*** %24
  %26 = getelementptr inbounds %literal*, %literal** %25, i32 1
  %27 = load %literal*, %literal** %26
  %28 = getelementptr inbounds %literal, %literal* %27, i32 0, i32 0
  %29 = load double, double* %28
  %30 = fcmp oeq double %29, 4.000000e+00
  br i1 %30, label %next2, label %error1

error1:                                           ; preds = %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @3, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next2

next2:                                            ; preds = %error1, %next
  %31 = bitcast %literal* %27 to %function_literal*
  %32 = getelementptr inbounds %function_literal, %function_literal* %31, i32 0, i32 2
  %33 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %32
  %34 = getelementptr inbounds %function_literal, %function_literal* %31, i32 0, i32 1
  %35 = load %literal**, %literal*** %34
  %params3 = call i8* @malloc(i32 8)
  %36 = bitcast i8* %params3 to %literal**
  %37 = getelementptr inbounds %literal*, %literal** %36, i32 0
  store %literal* %21, %literal** %37
  %38 = call %literal* %33(%literal** %35, %literal** %36)
  ret %literal* %38
}

