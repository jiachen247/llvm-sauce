; ModuleID = 'module'
source_filename = "module"

%literal = type { double, double }
%function_literal = type { double, %literal**, %literal* (%literal**, %literal**)* }

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
  store %literal* (%literal**, %literal**)* @__fact, %literal* (%literal**, %literal**)** %16
  %17 = bitcast %function_literal* %13 to %literal*
  %18 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %17, %literal** %18
  %19 = call i8* @malloc(i32 16)
  %20 = bitcast i8* %19 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  store double 1.000000e+00, double* %21
  store double 5.000000e+00, double* %22
  %23 = call i8* @malloc(i32 16)
  %24 = bitcast i8* %23 to %literal*
  %25 = getelementptr inbounds %literal, %literal* %24, i32 0, i32 0
  %26 = getelementptr inbounds %literal, %literal* %24, i32 0, i32 1
  store double 1.000000e+00, double* %25
  store double 1.000000e+00, double* %26
  %27 = getelementptr inbounds %literal, %literal* %17, i32 0, i32 0
  %28 = load double, double* %27
  %29 = fcmp oeq double %28, 4.000000e+00
  br i1 %29, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
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

define %literal* @__fact(%literal** %0, %literal** %1) {
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
  %16 = call i8* @malloc(i32 16)
  %17 = bitcast i8* %16 to %literal*
  %18 = getelementptr inbounds %literal, %literal* %17, i32 0, i32 0
  %19 = getelementptr inbounds %literal, %literal* %17, i32 0, i32 1
  store double 1.000000e+00, double* %18
  store double 1.000000e+00, double* %19
  %20 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %21 = getelementptr inbounds %literal, %literal* %17, i32 0, i32 1
  %22 = load double, double* %20
  %23 = load double, double* %21
  %24 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %25 = getelementptr inbounds %literal, %literal* %17, i32 0, i32 0
  %26 = load double, double* %24
  %27 = load double, double* %25
  %28 = fcmp oeq double %26, 1.000000e+00
  br i1 %28, label %tc.next, label %tc.error

tc.next:                                          ; preds = %f.entry
  %29 = fcmp oeq double %27, 1.000000e+00
  br i1 %29, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %30 = fcmp oeq double %22, %23
  %31 = uitofp i1 %30 to double
  %32 = call i8* @malloc(i32 16)
  %33 = bitcast i8* %32 to %literal*
  %34 = getelementptr inbounds %literal, %literal* %33, i32 0, i32 0
  %35 = getelementptr inbounds %literal, %literal* %33, i32 0, i32 1
  store double 2.000000e+00, double* %34
  store double %31, double* %35
  %36 = getelementptr inbounds %literal, %literal* %33, i32 0, i32 1
  %37 = load double, double* %36
  %38 = fptosi double %37 to i1
  br i1 %38, label %if.true, label %if.false

if.true:                                          ; preds = %tc.valid
  %env2 = call i8* @malloc(i32 8)
  %39 = bitcast i8* %env2 to %literal**
  %40 = bitcast %literal** %39 to %literal***
  store %literal** %10, %literal*** %40
  ret %literal* %8

if.false:                                         ; preds = %tc.valid
  %env3 = call i8* @malloc(i32 8)
  %41 = bitcast i8* %env3 to %literal**
  %42 = bitcast %literal** %41 to %literal***
  store %literal** %10, %literal*** %42
  %43 = call i8* @malloc(i32 16)
  %44 = bitcast i8* %43 to %literal*
  %45 = getelementptr inbounds %literal, %literal* %44, i32 0, i32 0
  %46 = getelementptr inbounds %literal, %literal* %44, i32 0, i32 1
  store double 1.000000e+00, double* %45
  store double 1.000000e+00, double* %46
  %47 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %48 = getelementptr inbounds %literal, %literal* %44, i32 0, i32 1
  %49 = load double, double* %47
  %50 = load double, double* %48
  %51 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %52 = getelementptr inbounds %literal, %literal* %44, i32 0, i32 0
  %53 = load double, double* %51
  %54 = load double, double* %52
  %55 = fcmp oeq double %53, 1.000000e+00
  br i1 %55, label %tc.next4, label %tc.error5

if.end:                                           ; No predecessors!
  ret %literal* %13

tc.next4:                                         ; preds = %if.false
  %56 = fcmp oeq double %54, 1.000000e+00
  br i1 %56, label %tc.valid6, label %tc.error5

tc.error5:                                        ; preds = %tc.next4, %if.false
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid6

tc.valid6:                                        ; preds = %tc.error5, %tc.next4
  %57 = fsub double %49, %50
  %58 = call i8* @malloc(i32 16)
  %59 = bitcast i8* %58 to %literal*
  %60 = getelementptr inbounds %literal, %literal* %59, i32 0, i32 0
  %61 = getelementptr inbounds %literal, %literal* %59, i32 0, i32 1
  store double 1.000000e+00, double* %60
  store double %57, double* %61
  %62 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %63 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  %64 = load double, double* %62
  %65 = load double, double* %63
  %66 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %67 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %68 = load double, double* %66
  %69 = load double, double* %67
  %70 = fcmp oeq double %68, 1.000000e+00
  br i1 %70, label %tc.next7, label %tc.error8

tc.next7:                                         ; preds = %tc.valid6
  %71 = fcmp oeq double %69, 1.000000e+00
  br i1 %71, label %tc.valid9, label %tc.error8

tc.error8:                                        ; preds = %tc.next7, %tc.valid6
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid9

tc.valid9:                                        ; preds = %tc.error8, %tc.next7
  %72 = fmul double %64, %65
  %73 = call i8* @malloc(i32 16)
  %74 = bitcast i8* %73 to %literal*
  %75 = getelementptr inbounds %literal, %literal* %74, i32 0, i32 0
  %76 = getelementptr inbounds %literal, %literal* %74, i32 0, i32 1
  store double 1.000000e+00, double* %75
  store double %72, double* %76
  %77 = bitcast %literal** %2 to %literal***
  %78 = load %literal**, %literal*** %77
  %79 = getelementptr inbounds %literal*, %literal** %78, i32 1
  %80 = load %literal*, %literal** %79
  %81 = getelementptr inbounds %literal, %literal* %80, i32 0, i32 0
  %82 = load double, double* %81
  %83 = fcmp oeq double %82, 4.000000e+00
  br i1 %83, label %next, label %error

error:                                            ; preds = %tc.valid9
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %tc.valid9
  %84 = bitcast %literal* %80 to %function_literal*
  %85 = getelementptr inbounds %function_literal, %function_literal* %84, i32 0, i32 2
  %86 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %85
  %87 = getelementptr inbounds %function_literal, %function_literal* %84, i32 0, i32 1
  %88 = load %literal**, %literal*** %87
  %params = call i8* @malloc(i32 16)
  %89 = bitcast i8* %params to %literal**
  %90 = getelementptr inbounds %literal*, %literal** %89, i32 0
  store %literal* %59, %literal** %90
  %91 = getelementptr inbounds %literal*, %literal** %89, i32 1
  store %literal* %74, %literal** %91
  %92 = call %literal* %86(%literal** %88, %literal** %89)
  ret %literal* %92
}

