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
  %36 = getelementptr inbounds %literal*, %literal** %5, i32 2
  %37 = load %literal*, %literal** %36
  %38 = getelementptr inbounds %literal*, %literal** %5, i32 1
  %39 = load %literal*, %literal** %38
  %40 = getelementptr inbounds %literal*, %literal** %5, i32 3
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
  %params = call i8* @malloc(i32 8)
  %50 = bitcast i8* %params to %literal**
  %51 = getelementptr inbounds %literal*, %literal** %50, i32 0
  store %literal* %39, %literal** %51
  %52 = call %literal* %47(%literal** %49, %literal** %50)
  %53 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 0
  %54 = load double, double* %53
  %55 = fcmp oeq double %54, 4.000000e+00
  br i1 %55, label %next3, label %error2

error2:                                           ; preds = %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @5, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next3

next3:                                            ; preds = %error2, %next
  %56 = bitcast %literal* %52 to %function_literal*
  %57 = getelementptr inbounds %function_literal, %function_literal* %56, i32 0, i32 2
  %58 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %57
  %59 = getelementptr inbounds %function_literal, %function_literal* %56, i32 0, i32 1
  %60 = load %literal**, %literal*** %59
  %params4 = call i8* @malloc(i32 8)
  %61 = bitcast i8* %params4 to %literal**
  %62 = getelementptr inbounds %literal*, %literal** %61, i32 0
  store %literal* %37, %literal** %62
  %63 = call %literal* %58(%literal** %60, %literal** %61)
  %64 = getelementptr inbounds %literal*, %literal** %5, i32 4
  store %literal* %63, %literal** %64
  %65 = call i8* @malloc(i32 16)
  %66 = bitcast i8* %65 to %literal*
  %67 = getelementptr inbounds %literal, %literal* %66, i32 0, i32 0
  %68 = getelementptr inbounds %literal, %literal* %66, i32 0, i32 1
  store double 1.000000e+00, double* %67
  store double 2.000000e+02, double* %68
  %69 = getelementptr inbounds %literal*, %literal** %5, i32 4
  %70 = load %literal*, %literal** %69
  %71 = getelementptr inbounds %literal, %literal* %70, i32 0, i32 0
  %72 = load double, double* %71
  %73 = fcmp oeq double %72, 4.000000e+00
  br i1 %73, label %next6, label %error5

error5:                                           ; preds = %next3
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @6, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next6

next6:                                            ; preds = %error5, %next3
  %74 = bitcast %literal* %70 to %function_literal*
  %75 = getelementptr inbounds %function_literal, %function_literal* %74, i32 0, i32 2
  %76 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %75
  %77 = getelementptr inbounds %function_literal, %function_literal* %74, i32 0, i32 1
  %78 = load %literal**, %literal*** %77
  %params7 = call i8* @malloc(i32 8)
  %79 = bitcast i8* %params7 to %literal**
  %80 = getelementptr inbounds %literal*, %literal** %79, i32 0
  store %literal* %66, %literal** %80
  %81 = call %literal* %76(%literal** %78, %literal** %79)
  call void @display(%literal* %81)
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
  %7 = getelementptr inbounds %literal*, %literal** %2, i32 1
  %8 = load %literal*, %literal** %7
  %9 = call i8* @malloc(i32 16)
  %10 = bitcast i8* %9 to %literal*
  %11 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 0
  %12 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 1
  store double 1.000000e+00, double* %11
  store double 1.000000e+00, double* %12
  %13 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  %14 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 1
  %15 = load double, double* %13
  %16 = load double, double* %14
  %17 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %18 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 0
  %19 = load double, double* %17
  %20 = load double, double* %18
  %21 = fcmp oeq double %19, 1.000000e+00
  br i1 %21, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %f.entry
  %22 = fcmp oeq double %20, 1.000000e+00
  br i1 %22, label %add.num, label %add.err

add.cstr1:                                        ; preds = %f.entry
  %23 = fcmp oeq double %19, 3.000000e+00
  br i1 %23, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %24 = fcmp oeq double %20, 3.000000e+00
  br i1 %24, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %25 = load double, double* %13
  %26 = load double, double* %14
  %27 = fadd double %25, %26
  %28 = call i8* @malloc(i32 16)
  %29 = bitcast i8* %28 to %literal*
  %30 = getelementptr inbounds %literal, %literal* %29, i32 0, i32 0
  %31 = getelementptr inbounds %literal, %literal* %29, i32 0, i32 1
  store double 1.000000e+00, double* %30
  store double %27, double* %31
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %32 = bitcast %literal* %8 to %string_literal*
  %33 = bitcast %literal* %10 to %string_literal*
  %34 = getelementptr inbounds %string_literal, %string_literal* %32, i32 0, i32 1
  %35 = getelementptr inbounds %string_literal, %string_literal* %33, i32 0, i32 1
  %36 = load i8*, i8** %34
  %37 = load i8*, i8** %35
  %38 = call i8* @strconcat(i8* %36, i8* %37)
  %39 = call i8* @malloc(i32 16)
  %40 = bitcast i8* %39 to %string_literal*
  %41 = getelementptr inbounds %string_literal, %string_literal* %40, i32 0, i32 0
  %42 = getelementptr inbounds %string_literal, %string_literal* %40, i32 0, i32 1
  store double 3.000000e+00, double* %41
  store i8* %38, i8** %42
  %43 = bitcast %string_literal* %40 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %44 = phi %literal* [ %29, %add.num ], [ %43, %add.str ]
  ret %literal* %44
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
  %7 = getelementptr inbounds %literal*, %literal** %2, i32 1
  %8 = load %literal*, %literal** %7
  %9 = call i8* @malloc(i32 16)
  %10 = bitcast i8* %9 to %literal*
  %11 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 0
  %12 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 1
  store double 1.000000e+00, double* %11
  store double 2.000000e+00, double* %12
  %13 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  %14 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 1
  %15 = load double, double* %13
  %16 = load double, double* %14
  %17 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %18 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 0
  %19 = load double, double* %17
  %20 = load double, double* %18
  %21 = fcmp oeq double %19, 1.000000e+00
  br i1 %21, label %tc.next, label %tc.error

tc.next:                                          ; preds = %f.entry
  %22 = fcmp oeq double %20, 1.000000e+00
  br i1 %22, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %23 = fmul double %15, %16
  %24 = call i8* @malloc(i32 16)
  %25 = bitcast i8* %24 to %literal*
  %26 = getelementptr inbounds %literal, %literal* %25, i32 0, i32 0
  %27 = getelementptr inbounds %literal, %literal* %25, i32 0, i32 1
  store double 1.000000e+00, double* %26
  store double %23, double* %27
  ret %literal* %25
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
  %7 = getelementptr inbounds %literal*, %literal** %2, i32 1
  %8 = load %literal*, %literal** %7
  %9 = bitcast %literal** %2 to %literal***
  %10 = load %literal**, %literal*** %9
  %11 = getelementptr inbounds %literal*, %literal** %10, i32 1
  %12 = load %literal*, %literal** %11
  %13 = getelementptr inbounds %literal, %literal* %12, i32 0, i32 0
  %14 = load double, double* %13
  %15 = fcmp oeq double %14, 4.000000e+00
  br i1 %15, label %next, label %error

error:                                            ; preds = %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @2, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %f.entry
  %16 = bitcast %literal* %12 to %function_literal*
  %17 = getelementptr inbounds %function_literal, %function_literal* %16, i32 0, i32 2
  %18 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %17
  %19 = getelementptr inbounds %function_literal, %function_literal* %16, i32 0, i32 1
  %20 = load %literal**, %literal*** %19
  %params = call i8* @malloc(i32 8)
  %21 = bitcast i8* %params to %literal**
  %22 = getelementptr inbounds %literal*, %literal** %21, i32 0
  store %literal* %8, %literal** %22
  %23 = call %literal* %18(%literal** %20, %literal** %21)
  %24 = bitcast %literal** %2 to %literal***
  %25 = load %literal**, %literal*** %24
  %26 = bitcast %literal** %25 to %literal***
  %27 = load %literal**, %literal*** %26
  %28 = getelementptr inbounds %literal*, %literal** %27, i32 1
  %29 = load %literal*, %literal** %28
  %30 = getelementptr inbounds %literal, %literal* %29, i32 0, i32 0
  %31 = load double, double* %30
  %32 = fcmp oeq double %31, 4.000000e+00
  br i1 %32, label %next2, label %error1

error1:                                           ; preds = %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @3, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next2

next2:                                            ; preds = %error1, %next
  %33 = bitcast %literal* %29 to %function_literal*
  %34 = getelementptr inbounds %function_literal, %function_literal* %33, i32 0, i32 2
  %35 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %34
  %36 = getelementptr inbounds %function_literal, %function_literal* %33, i32 0, i32 1
  %37 = load %literal**, %literal*** %36
  %params3 = call i8* @malloc(i32 8)
  %38 = bitcast i8* %params3 to %literal**
  %39 = getelementptr inbounds %literal*, %literal** %38, i32 0
  store %literal* %23, %literal** %39
  %40 = call %literal* %35(%literal** %37, %literal** %38)
  ret %literal* %40
}

