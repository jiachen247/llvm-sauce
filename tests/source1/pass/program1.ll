; ModuleID = 'module'
source_filename = "module"

%literal = type { double, double }
%string_literal = type { double, i8* }

@format_number = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1
@format_true = private unnamed_addr constant [6 x i8] c"true\0A\00", align 1
@format_false = private unnamed_addr constant [7 x i8] c"false\0A\00", align 1
@format_string = private unnamed_addr constant [6 x i8] c"\22%s\22\0A\00", align 1
@format_function = private unnamed_addr constant [17 x i8] c"function object\0A\00", align 1
@format_undef = private unnamed_addr constant [11 x i8] c"undefined\0A\00", align 1
@format_error = private unnamed_addr constant [13 x i8] c"error: \22%s\22\0A\00", align 1
@0 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@s = private unnamed_addr constant [13 x i8] c"Hello world!\00", align 1
@s.1 = private unnamed_addr constant [4 x i8] c"boo\00", align 1

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
  %13 = bitcast i8* %12 to %literal*
  %14 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 0
  %15 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 1
  store double 1.000000e+00, double* %14
  store double 1.000000e+00, double* %15
  %16 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %13, %literal** %16
  %env2 = call i8* @malloc(i32 16)
  %17 = bitcast i8* %env2 to %literal**
  %18 = bitcast %literal** %17 to %literal***
  store %literal** %5, %literal*** %18
  %19 = getelementptr inbounds %literal*, %literal** %17, i32 1
  store %literal* %8, %literal** %19
  %20 = call i8* @malloc(i32 16)
  %21 = bitcast i8* %20 to %literal*
  %22 = getelementptr inbounds %literal, %literal* %21, i32 0, i32 0
  %23 = getelementptr inbounds %literal, %literal* %21, i32 0, i32 1
  store double 1.000000e+00, double* %22
  store double 2.000000e+00, double* %23
  %24 = getelementptr inbounds %literal*, %literal** %17, i32 1
  store %literal* %21, %literal** %24
  %25 = call i8* @malloc(i32 16)
  %26 = bitcast i8* %25 to %literal*
  %27 = getelementptr inbounds %literal, %literal* %26, i32 0, i32 0
  %28 = getelementptr inbounds %literal, %literal* %26, i32 0, i32 1
  store double 1.000000e+00, double* %27
  store double 2.000000e+00, double* %28
  %29 = getelementptr inbounds %literal, %literal* %21, i32 0, i32 1
  %30 = getelementptr inbounds %literal, %literal* %26, i32 0, i32 1
  %31 = load double, double* %29
  %32 = load double, double* %30
  %33 = getelementptr inbounds %literal, %literal* %21, i32 0, i32 0
  %34 = getelementptr inbounds %literal, %literal* %26, i32 0, i32 0
  %35 = load double, double* %33
  %36 = load double, double* %34
  %37 = fcmp oeq double %35, 1.000000e+00
  br i1 %37, label %tc.next, label %tc.error

tc.next:                                          ; preds = %entry
  %38 = fcmp oeq double %36, 1.000000e+00
  br i1 %38, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %39 = fmul double %31, %32
  %40 = call i8* @malloc(i32 16)
  %41 = bitcast i8* %40 to %literal*
  %42 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 0
  %43 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 1
  store double 1.000000e+00, double* %42
  store double %39, double* %43
  %44 = call i8* @malloc(i32 16)
  %45 = bitcast i8* %44 to %literal*
  %46 = getelementptr inbounds %literal, %literal* %45, i32 0, i32 0
  %47 = getelementptr inbounds %literal, %literal* %45, i32 0, i32 1
  store double 1.000000e+00, double* %46
  store double 4.000000e+00, double* %47
  %48 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 1
  %49 = getelementptr inbounds %literal, %literal* %45, i32 0, i32 1
  %50 = load double, double* %48
  %51 = load double, double* %49
  %52 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 0
  %53 = getelementptr inbounds %literal, %literal* %45, i32 0, i32 0
  %54 = load double, double* %52
  %55 = load double, double* %53
  %56 = fcmp oeq double %54, 1.000000e+00
  br i1 %56, label %tc.next3, label %tc.error4

tc.next3:                                         ; preds = %tc.valid
  %57 = fcmp oeq double %55, 1.000000e+00
  br i1 %57, label %tc.valid5, label %tc.error4

tc.error4:                                        ; preds = %tc.next3, %tc.valid
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid5

tc.valid5:                                        ; preds = %tc.error4, %tc.next3
  %58 = fcmp oeq double %50, %51
  %59 = uitofp i1 %58 to double
  %60 = call i8* @malloc(i32 16)
  %61 = bitcast i8* %60 to %literal*
  %62 = getelementptr inbounds %literal, %literal* %61, i32 0, i32 0
  %63 = getelementptr inbounds %literal, %literal* %61, i32 0, i32 1
  store double 2.000000e+00, double* %62
  store double %59, double* %63
  %64 = getelementptr inbounds %literal, %literal* %61, i32 0, i32 1
  %65 = load double, double* %64
  %66 = fptosi double %65 to i1
  br i1 %66, label %if.true, label %if.false

if.true:                                          ; preds = %tc.valid5
  %env6 = call i8* @malloc(i32 8)
  %67 = bitcast i8* %env6 to %literal**
  %68 = bitcast %literal** %67 to %literal***
  store %literal** %17, %literal*** %68
  %69 = call i8* @malloc(i32 16)
  %70 = bitcast i8* %69 to %string_literal*
  %71 = getelementptr inbounds %string_literal, %string_literal* %70, i32 0, i32 0
  %72 = getelementptr inbounds %string_literal, %string_literal* %70, i32 0, i32 1
  store double 3.000000e+00, double* %71
  store i8* getelementptr inbounds ([13 x i8], [13 x i8]* @s, i32 0, i32 0), i8** %72
  %73 = bitcast %string_literal* %70 to %literal*
  call void @display(%literal* %73)
  br label %if.end

if.false:                                         ; preds = %tc.valid5
  %env7 = call i8* @malloc(i32 8)
  %74 = bitcast i8* %env7 to %literal**
  %75 = bitcast %literal** %74 to %literal***
  store %literal** %17, %literal*** %75
  %76 = call i8* @malloc(i32 16)
  %77 = bitcast i8* %76 to %string_literal*
  %78 = getelementptr inbounds %string_literal, %string_literal* %77, i32 0, i32 0
  %79 = getelementptr inbounds %string_literal, %string_literal* %77, i32 0, i32 1
  store double 3.000000e+00, double* %78
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @s.1, i32 0, i32 0), i8** %79
  %80 = bitcast %string_literal* %77 to %literal*
  call void @display(%literal* %80)
  br label %if.end

if.end:                                           ; preds = %if.false, %if.true
  %81 = phi %literal* [ %8, %if.true ], [ %8, %if.false ]
  call void @display(%literal* %81)
  ret i32 0
}

