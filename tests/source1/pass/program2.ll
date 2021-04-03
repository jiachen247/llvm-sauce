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
@1 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@2 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@3 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@4 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1

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
  store %literal* (%literal**, %literal**)* @__factorial, %literal* (%literal**, %literal**)** %16
  %17 = bitcast %function_literal* %13 to %literal*
  %18 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %17, %literal** %18
  %19 = call i8* @malloc(i32 16)
  %20 = bitcast i8* %19 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  store double 1.000000e+00, double* %21
  store double 5.000000e+00, double* %22
  %23 = getelementptr inbounds %literal*, %literal** %5, i32 1
  %24 = load %literal*, %literal** %23
  %25 = getelementptr inbounds %literal, %literal* %24, i32 0, i32 0
  %26 = load double, double* %25
  %27 = fcmp oeq double %26, 4.000000e+00
  br i1 %27, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @4, i32 0, i32 0))
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

define %literal* @__factorial(%literal** %0, %literal** %1) {
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
  br i1 %29, label %tc.next, label %tc.error

tc.next:                                          ; preds = %f.entry
  %30 = fcmp oeq double %28, 1.000000e+00
  br i1 %30, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %31 = fcmp oeq double %23, %24
  %32 = uitofp i1 %31 to double
  %33 = call i8* @malloc(i32 16)
  %34 = bitcast i8* %33 to %literal*
  %35 = getelementptr inbounds %literal, %literal* %34, i32 0, i32 0
  %36 = getelementptr inbounds %literal, %literal* %34, i32 0, i32 1
  store double 2.000000e+00, double* %35
  store double %32, double* %36
  %37 = getelementptr inbounds %literal, %literal* %34, i32 0, i32 1
  %38 = load double, double* %37
  %39 = fptosi double %38 to i1
  br i1 %39, label %tenary.true, label %tenary.false

tenary.true:                                      ; preds = %tc.valid
  %40 = call i8* @malloc(i32 16)
  %41 = bitcast i8* %40 to %literal*
  %42 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 0
  %43 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 1
  store double 1.000000e+00, double* %42
  store double 1.000000e+00, double* %43
  br label %tenary.end

tenary.false:                                     ; preds = %tc.valid
  %44 = bitcast %literal** %7 to %literal***
  %45 = load %literal**, %literal*** %44
  %46 = getelementptr inbounds %literal*, %literal** %45, i32 1
  %47 = load %literal*, %literal** %46
  %48 = bitcast %literal** %7 to %literal***
  %49 = load %literal**, %literal*** %48
  %50 = getelementptr inbounds %literal*, %literal** %49, i32 1
  %51 = load %literal*, %literal** %50
  %52 = call i8* @malloc(i32 16)
  %53 = bitcast i8* %52 to %literal*
  %54 = getelementptr inbounds %literal, %literal* %53, i32 0, i32 0
  %55 = getelementptr inbounds %literal, %literal* %53, i32 0, i32 1
  store double 1.000000e+00, double* %54
  store double 1.000000e+00, double* %55
  %56 = getelementptr inbounds %literal, %literal* %51, i32 0, i32 1
  %57 = getelementptr inbounds %literal, %literal* %53, i32 0, i32 1
  %58 = load double, double* %56
  %59 = load double, double* %57
  %60 = getelementptr inbounds %literal, %literal* %51, i32 0, i32 0
  %61 = getelementptr inbounds %literal, %literal* %53, i32 0, i32 0
  %62 = load double, double* %60
  %63 = load double, double* %61
  %64 = fcmp oeq double %62, 1.000000e+00
  br i1 %64, label %tc.next2, label %tc.error3

tenary.end:                                       ; preds = %tc.valid7, %tenary.true
  %65 = phi %literal* [ %41, %tenary.true ], [ %101, %tc.valid7 ]
  ret %literal* %65

tc.next2:                                         ; preds = %tenary.false
  %66 = fcmp oeq double %63, 1.000000e+00
  br i1 %66, label %tc.valid4, label %tc.error3

tc.error3:                                        ; preds = %tc.next2, %tenary.false
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid4

tc.valid4:                                        ; preds = %tc.error3, %tc.next2
  %67 = fsub double %58, %59
  %68 = call i8* @malloc(i32 16)
  %69 = bitcast i8* %68 to %literal*
  %70 = getelementptr inbounds %literal, %literal* %69, i32 0, i32 0
  %71 = getelementptr inbounds %literal, %literal* %69, i32 0, i32 1
  store double 1.000000e+00, double* %70
  store double %67, double* %71
  %72 = bitcast %literal** %7 to %literal***
  %73 = load %literal**, %literal*** %72
  %74 = bitcast %literal** %73 to %literal***
  %75 = load %literal**, %literal*** %74
  %76 = getelementptr inbounds %literal*, %literal** %75, i32 1
  %77 = load %literal*, %literal** %76
  %78 = getelementptr inbounds %literal, %literal* %77, i32 0, i32 0
  %79 = load double, double* %78
  %80 = fcmp oeq double %79, 4.000000e+00
  br i1 %80, label %next, label %error

error:                                            ; preds = %tc.valid4
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @2, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %tc.valid4
  %81 = bitcast %literal* %77 to %function_literal*
  %82 = getelementptr inbounds %function_literal, %function_literal* %81, i32 0, i32 2
  %83 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %82
  %84 = getelementptr inbounds %function_literal, %function_literal* %81, i32 0, i32 1
  %85 = load %literal**, %literal*** %84
  %params = call i8* @malloc(i32 8)
  %86 = bitcast i8* %params to %literal**
  %87 = getelementptr inbounds %literal*, %literal** %86, i32 0
  store %literal* %69, %literal** %87
  %88 = call %literal* %83(%literal** %85, %literal** %86)
  %89 = getelementptr inbounds %literal, %literal* %47, i32 0, i32 1
  %90 = getelementptr inbounds %literal, %literal* %88, i32 0, i32 1
  %91 = load double, double* %89
  %92 = load double, double* %90
  %93 = getelementptr inbounds %literal, %literal* %47, i32 0, i32 0
  %94 = getelementptr inbounds %literal, %literal* %88, i32 0, i32 0
  %95 = load double, double* %93
  %96 = load double, double* %94
  %97 = fcmp oeq double %95, 1.000000e+00
  br i1 %97, label %tc.next5, label %tc.error6

tc.next5:                                         ; preds = %next
  %98 = fcmp oeq double %96, 1.000000e+00
  br i1 %98, label %tc.valid7, label %tc.error6

tc.error6:                                        ; preds = %tc.next5, %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @3, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid7

tc.valid7:                                        ; preds = %tc.error6, %tc.next5
  %99 = fmul double %91, %92
  %100 = call i8* @malloc(i32 16)
  %101 = bitcast i8* %100 to %literal*
  %102 = getelementptr inbounds %literal, %literal* %101, i32 0, i32 0
  %103 = getelementptr inbounds %literal, %literal* %101, i32 0, i32 1
  store double 1.000000e+00, double* %102
  store double %99, double* %103
  br label %tenary.end
}

