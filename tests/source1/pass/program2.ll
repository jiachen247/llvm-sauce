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
  %23 = getelementptr inbounds %literal, %literal* %17, i32 0, i32 0
  %24 = load double, double* %23
  %25 = fcmp oeq double %24, 4.000000e+00
  br i1 %25, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
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
  br i1 %25, label %tc.next, label %tc.error

tc.next:                                          ; preds = %f.entry
  %26 = fcmp oeq double %24, 1.000000e+00
  br i1 %26, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %27 = fcmp oeq double %19, %20
  %28 = uitofp i1 %27 to double
  %29 = call i8* @malloc(i32 16)
  %30 = bitcast i8* %29 to %literal*
  %31 = getelementptr inbounds %literal, %literal* %30, i32 0, i32 0
  %32 = getelementptr inbounds %literal, %literal* %30, i32 0, i32 1
  store double 2.000000e+00, double* %31
  store double %28, double* %32
  %33 = getelementptr inbounds %literal, %literal* %30, i32 0, i32 1
  %34 = load double, double* %33
  %35 = fptosi double %34 to i1
  br i1 %35, label %tenary.true, label %tenary.false

tenary.true:                                      ; preds = %tc.valid
  %36 = call i8* @malloc(i32 16)
  %37 = bitcast i8* %36 to %literal*
  %38 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 0
  %39 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 1
  store double 1.000000e+00, double* %38
  store double 1.000000e+00, double* %39
  br label %tenary.end

tenary.false:                                     ; preds = %tc.valid
  %40 = call i8* @malloc(i32 16)
  %41 = bitcast i8* %40 to %literal*
  %42 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 0
  %43 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 1
  store double 1.000000e+00, double* %42
  store double 1.000000e+00, double* %43
  %44 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %45 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 1
  %46 = load double, double* %44
  %47 = load double, double* %45
  %48 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %49 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 0
  %50 = load double, double* %48
  %51 = load double, double* %49
  %52 = fcmp oeq double %50, 1.000000e+00
  br i1 %52, label %tc.next2, label %tc.error3

tenary.end:                                       ; preds = %tc.valid7, %tenary.true
  %53 = phi %literal* [ %37, %tenary.true ], [ %87, %tc.valid7 ]
  ret %literal* %53

tc.next2:                                         ; preds = %tenary.false
  %54 = fcmp oeq double %51, 1.000000e+00
  br i1 %54, label %tc.valid4, label %tc.error3

tc.error3:                                        ; preds = %tc.next2, %tenary.false
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid4

tc.valid4:                                        ; preds = %tc.error3, %tc.next2
  %55 = fsub double %46, %47
  %56 = call i8* @malloc(i32 16)
  %57 = bitcast i8* %56 to %literal*
  %58 = getelementptr inbounds %literal, %literal* %57, i32 0, i32 0
  %59 = getelementptr inbounds %literal, %literal* %57, i32 0, i32 1
  store double 1.000000e+00, double* %58
  store double %55, double* %59
  %60 = bitcast %literal** %2 to %literal***
  %61 = load %literal**, %literal*** %60
  %62 = getelementptr inbounds %literal*, %literal** %61, i32 1
  %63 = load %literal*, %literal** %62
  %64 = getelementptr inbounds %literal, %literal* %63, i32 0, i32 0
  %65 = load double, double* %64
  %66 = fcmp oeq double %65, 4.000000e+00
  br i1 %66, label %next, label %error

error:                                            ; preds = %tc.valid4
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %tc.valid4
  %67 = bitcast %literal* %63 to %function_literal*
  %68 = getelementptr inbounds %function_literal, %function_literal* %67, i32 0, i32 2
  %69 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %68
  %70 = getelementptr inbounds %function_literal, %function_literal* %67, i32 0, i32 1
  %71 = load %literal**, %literal*** %70
  %params = call i8* @malloc(i32 8)
  %72 = bitcast i8* %params to %literal**
  %73 = getelementptr inbounds %literal*, %literal** %72, i32 0
  store %literal* %57, %literal** %73
  %74 = call %literal* %69(%literal** %71, %literal** %72)
  %75 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %76 = getelementptr inbounds %literal, %literal* %74, i32 0, i32 1
  %77 = load double, double* %75
  %78 = load double, double* %76
  %79 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %80 = getelementptr inbounds %literal, %literal* %74, i32 0, i32 0
  %81 = load double, double* %79
  %82 = load double, double* %80
  %83 = fcmp oeq double %81, 1.000000e+00
  br i1 %83, label %tc.next5, label %tc.error6

tc.next5:                                         ; preds = %next
  %84 = fcmp oeq double %82, 1.000000e+00
  br i1 %84, label %tc.valid7, label %tc.error6

tc.error6:                                        ; preds = %tc.next5, %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid7

tc.valid7:                                        ; preds = %tc.error6, %tc.next5
  %85 = fmul double %77, %78
  %86 = call i8* @malloc(i32 16)
  %87 = bitcast i8* %86 to %literal*
  %88 = getelementptr inbounds %literal, %literal* %87, i32 0, i32 0
  %89 = getelementptr inbounds %literal, %literal* %87, i32 0, i32 1
  store double 1.000000e+00, double* %88
  store double %85, double* %89
  br label %tenary.end
}

