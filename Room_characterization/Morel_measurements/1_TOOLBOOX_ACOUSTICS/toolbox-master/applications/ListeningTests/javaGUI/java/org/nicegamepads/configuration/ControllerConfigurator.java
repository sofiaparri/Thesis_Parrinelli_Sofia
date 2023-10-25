package org.nicegamepads.configuration;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import org.nicegamepads.CalibrationBuilder;
import org.nicegamepads.CalibrationListener;
import org.nicegamepads.CalibrationResults;
import org.nicegamepads.ControlEvent;
import org.nicegamepads.ControlPollingListener;
import org.nicegamepads.ControllerManager;
import org.nicegamepads.ControllerPoller;
import org.nicegamepads.LoggingRunnable;
import org.nicegamepads.NiceControl;
import org.nicegamepads.NiceControlType;
import org.nicegamepads.NiceController;
import org.nicegamepads.Range;


/**
 * A useful tool for configuring a controller.
 * 
 * @author Andrew Hayden
 */
public class ControllerConfigurator
{
    /**
     * The controller to configure.
     */
    private final NiceController controller;

    /**
     * The configuration that will be generated by this configurator.
     */
    private final ControllerConfigurationBuilder configBuilder;

    /**
     * Controls that can be configured by this configurator.
     */
    private final Set<NiceControl> eligibleControls;

    /**
     * Synchronization lock.
     */
    private final Object lock = new Object();

    /**
     * The thread that is waiting for identification, if any.
     */
    private volatile Thread identificationThread = null;

    /**
     * The current calibration listener, if any.
     */
    private volatile CalibrationHelper calibrationHelper = null;

    /**
     * Whether or not we are currently calibrating.
     */
    private boolean calibrating = false;

    /**
     * Listeners.
     */
    private final List<CalibrationListener> calibrationListeners
        = new CopyOnWriteArrayList<CalibrationListener>();

    /**
     * Constructs a new configurator to configure the specified controller.
     * 
     * @param controller the controller to be configured
     */
    public ControllerConfigurator(NiceController controller) {
        this(controller, null);
    }

    /**
     * Constructs a new configurator to configure the specified controller,
     * optionally using a specified configuration to provide defaults.
     * <p>
     * If an optional default configuration is specified, a copy of that
     * configuration is made and serves as the basis for the configurator
     * operations.  This is a convenient way to "inherit" an existing
     * configuration and only update it piecemeal.
     * <p>
     * 
     * @param controller the controller to be configured
     * @param defaultConfiguration (optional) a default configuration
     * to copy before configuration begins
     */
    public ControllerConfigurator(final NiceController controller, final ControllerConfiguration defaultConfiguration) {
        this.controller = controller;
        this.configBuilder = new ControllerConfigurationBuilder(controller);
        if (defaultConfiguration != null) {
            configBuilder.loadFrom(defaultConfiguration);
        }
        this.controller.setConfiguration(defaultConfiguration);
        eligibleControls = new HashSet<NiceControl>(controller.getControls());
    }

    /**
     * Adds a listner to be notified of calibration events.
     * 
     * @param listener the listener to add
     */
    public void addCalibrationListener(final CalibrationListener listener) {
        calibrationListeners.add(listener);
    }

    /**
     * Removes a previously-registered listner.
     * 
     * @param listener the listener to remove
     */
    public void removeCalibrationListener(final CalibrationListener listener) {
        calibrationListeners.remove(listener);
    }

    /**
     * Convenience method to call
     * <code>identifyControl(0, null, null)</code> (wait forever, identify
     * any type of control).
     * 
     * @return see {@link #identifyControl(long, TimeUnit, ControlType))}
     * @throws InterruptedException if interrupted while waiting
     */
    public ControlEvent identifyControl() throws InterruptedException {
        return identifyControl(0L, null, null, null);
    }

    /**
     * Convenience method to call
     * <code>identifyControl(0, null, new Set<NiceControlType>(
     * Arrays.asList(new ControlType[] {requiredType}),
     * ineligibleControls)</code>
     * (wait forever, identify only the specified type of control and
     * don't identify if the control is listed in the specified set of
     * ineligible controls).
     * 
     * @param allowedType optionally, the type of control to be identified
     * @param ineligibleControls optionally, a set of controls that are
     * ineligible for identification; typically useful when you want to prevent
     * the same control from being identified more than once
     * @return see {@link #identifyControl(long, TimeUnit, ControlType))}
     * @throws InterruptedException if interrupted while waiting
     */
    public ControlEvent identifyControl(final NiceControlType allowedType, final Set<NiceControl> ineligibleControls)
    throws InterruptedException {
        Set<NiceControlType> typeSet = null;
        if (allowedType != null)
        {
            typeSet = new HashSet<NiceControlType>();
            typeSet.add(allowedType);
        }

        return identifyControl(0L, null, typeSet, ineligibleControls);
    }

    /**
     * Attempts to synchronously identify a control by waiting up to
     * a specified amount of time for a qualifying event to be generated
     * by the controller.
     * <p>
     * A qualifying event is an event that clearly indicates that the device
     * has received interesting input.  This is defined as follows:
     * <ol>
     *  <li>For buttons and keys: the value of a control reaches the value
     *      1.0f and then returns to 0.0f.</li>
     *  <li>For relative axes: the value of a control reaches any non-zero
     *      value (e.g., wheel is turned, mouse is moved, etc)</li>
     *  <li>For point-of-view hats: the value of a control reaches any
     *      non-zero value and then returns to 0.0f.</li>
     *  <li>Everything else: the value of a control reaches either -1.0f
     *      of 1.0f, and then returns to 0.0f.  This is generally analgous
     *      to the axis being "pushed" all the way to one of its limits and
     *      then released.</li> 
     * </ol>
     * <p>
     * The return value of this method is a {@link ControlEvent}.
     * This return value, when not <code>null</code>, contains a complete
     * description of the qualifying event.  The <code>previousValue</code>
     * field of the event is set to the non-zero value that qualified the
     * event.  The <code>currentValue</code> contains the final value was that
     * completed the qualification (in the case of relative axes, the same
     * non-zero value is in both fields; in all other cases, the current value
     * should be 0.0f since that is the only value that can complete a
     * qualifying event).
     * <p>
     * <strong>It is an error to modify the specified set before this method
     * has returned.</strong>.  That is, this method <em>does not</em> make
     * a copy of the map.  The reason this is so is because the method is
     * blocking and the only guarantee that could otherwise be made would be
     * "it is safe to modify the map only after the method returns".  Since
     * that doesn't buy us anything, we just don't make a defensive copy at
     * all.
     * 
     * @param timeout the maximum amount of time to wait
     * @param unit the unit of the maximum time to wait
     * @param allowedTypes (optional) the types of control that may
     * be identified; input from any other types of control is ignored.
     * If not specified, any type of control may be identified.
     * @param ineligibleControls (optional) the controls that are
     * ineligible for identification; typically used to prevent duplicate
     * identifications of the same control
     * @return if a qualifying event occurs before the timeout period, the
     * event that contains the qualifying event; otherwise, <code>null</code>
     * @throws InterruptedException  if interrupted while waiting
     */
    public ControlEvent identifyControl(long timeout, TimeUnit unit,
            Set<NiceControlType> allowedTypes,
            Set<NiceControl> ineligibleControls)
    throws InterruptedException {
        synchronized(lock) {
            if (identificationThread != null) {
                throw new IllegalStateException("Already identifying.");
            }
            if (calibrating) {
                throw new IllegalStateException("Already calibrating.");
            }

            ControllerPoller poller = ControllerPoller.getInstance(controller);
            identificationThread = Thread.currentThread();

            final CountDownLatch latch = new CountDownLatch(1);
            final IdentificationListener myListener = new IdentificationListener(latch, allowedTypes, ineligibleControls);
            poller.addControlPollingListener(myListener);

            boolean success = false;
            try {
                if (timeout != 0L) {
                    success = latch.await(timeout, unit);
                } else {
                    latch.await();
                    success = true;
                }
            } finally {
                // Always remove the listener and halt polling!
                poller.removeControlPollingListener(myListener);
                identificationThread = null;
            }

            if (success) {
                return myListener.winner;
            } else {
                return null;
            }
        }
    }

    /**
     * Begins calibration.
     * <p>
     * During calibration, the high and low values for each control are
     * tracked constantly.  The highest and lowest values seen during
     * calibration are available 
     */
    public void startCalibrating() {
        synchronized(lock) {
            if (identificationThread != null) {
                throw new IllegalStateException("Already identifying.");
            }
            if (calibrating) {
                throw new IllegalStateException("Already calibrating.");
            }

            // Start calibration.
            calibrating = true;
            calibrationHelper = new CalibrationHelper();
            calibrationHelper.start();
            ControllerPoller.getInstance(controller).addControlPollingListener(calibrationHelper);

            ControllerManager.getEventDispatcher().submit(new LoggingRunnable(){
                @Override
                protected void runInternal() {
                    for (CalibrationListener listener : calibrationListeners) {
                        listener.calibrationStarted(controller);
                    }
                }
            });
        }
    }

    /**
     * Stops calibrating and returns the results of calibration.
     * 
     * @return the results of calibration
     */
    public CalibrationResults stopCalibrating() {
        synchronized(lock) {
            if (!calibrating) {
                throw new IllegalStateException("Not currently calibrating.");
            }

            // Stop calibration.
            calibrationHelper.stop();
            ControllerPoller.getInstance(controller).removeControlPollingListener(calibrationHelper);
            calibrating = false;

            ControllerManager.getEventDispatcher().submit(new LoggingRunnable(){
                @Override
                protected void runInternal() {
                    for (CalibrationListener listener : calibrationListeners) {
                        listener.calibrationStopped(controller, calibrationHelper.builder.build());
                    }
                }
            });

            return calibrationHelper.builder.build();
        }
    }
    
    /**
     * Returns true if and only if the specified value lies within the
     * specified dead zone.
     * 
     * @param value the value to check
     * @param deadZoneLowerBound the lower bound of the dead zone, or NaN
     * @param deadZoneUpperBound the upper bound of the dead zone, or NaN
     * @return as described
     */
    private final static boolean inDeadZone(final float value, final float deadZoneLowerBound, final float deadZoneUpperBound) {
        if (!Float.isNaN(deadZoneLowerBound)) {
            if (value <= 0 && value >= deadZoneLowerBound) {
                return true;
            }
        }
        if (!Float.isNaN(deadZoneUpperBound)) {
            if (value >= 0 && value <= deadZoneUpperBound) {
                return true;
            }
        }
        return false;
    }

    /**
     * Listens for polling events and identifies the first control to
     * reach the end of its range and return to neutral.
     * 
     * @author Andrew Hayden
     */
    private final class IdentificationListener implements ControlPollingListener {
        /**
         * Map of whether or not a bound has been reached, by related
         * control.
         */
        private final Map<NiceControl, Boolean> boundsReachedByControl =
            Collections.synchronizedMap(new HashMap<NiceControl, Boolean>());

        /**
         * The value that qualified the associated control as a potential
         * winner.
         */
        private final Map<NiceControl, Float> qualifyingValueByControl =
            Collections.synchronizedMap(new HashMap<NiceControl, Float>());

        /**
         * Lock used for synchronization.
         */
        private final CountDownLatch latch;

        /**
         * Optional allowed types of control to identify;
         * if specified, events from all other types of controls are ignored.
         */
        private final Set<NiceControlType> allowedTypes;

        /**
         * Optional set of controls that are ineligible for identification;
         * if specified, events from these controls are ignored
         */
        private final Set<NiceControl> ineligibleControls;

        /**
         * The control that has won.
         */
        private volatile ControlEvent winner = null;

        /**
         * Constructs a new stateful listener.
         * <p>
         * 
         * @param latch the latch to count down when done
         * @param allowedTypes optionally, the set of types that are allowed
         * to be identified; if <code>null</code>, any type may be identified
         * @param ineligibleControls optionally, the set of controls
         * that are ineligible for identification; if <code>null</code>,
         * any control may be identified so long as its type is allowed
         */
        IdentificationListener(final CountDownLatch latch,
                final Set<NiceControlType> allowedTypes,
                final Set<NiceControl> ineligibleControls) {
            this.latch = latch;
            this.allowedTypes = allowedTypes;
            this.ineligibleControls = ineligibleControls;
        }

        @Override
        public final void controlPolled(final ControlEvent event) {
            //System.out.println(event);
            if (event.sourceControl == null || winner != null
                    || !eligibleControls.contains(event.sourceControl)) {
                // Unknown control, or already done.  Ignore input.
                return;
            }

            if (allowedTypes != null && !allowedTypes.contains(
                    event.sourceControl.getControlType())) {
                // Allowed types are constrained, but control type doesn't
                // meet the constraints.  Ignore input.
                return;
            }

            if (ineligibleControls != null
                    && ineligibleControls.contains(event.sourceControl)) {
                // Ineligible controls have been identified, and source
                // control is on the list.  Ignore input.
                return;
            }

            boolean boundsHit = false;

            // Scoping block.  Don't want 'test' hanging out.
            {
                final Boolean test =  boundsReachedByControl.get(event.sourceControl);
                if (test != null) {
                    boundsHit = test;
                }
            }

            if (event.sourceControl.getControlType() == NiceControlType.DISCRETE_INPUT) {
                // Discrete controls report precise values.
                // Wait for a non-zero value.
                if (event.currentValue != 0f) {
                    boundsReachedByControl.put(event.sourceControl, Boolean.TRUE);
                    qualifyingValueByControl.put(event.sourceControl, event.currentValue);
                } else if (boundsHit) {
                    // Have found a non-zero value, and current value is zero.
                    // Winner!
                    winner = event;
                }
            } else if (event.sourceControl.getControlType() == NiceControlType.CONTINUOUS_INPUT) {
                // Continuous controls can theoretically take on any value
                // in the allowed range.  These are usually analog in nature.
                // We obey any dead zone settings here so that we don't "identify"
                // a control that is just jittery near its center (as many
                // analog controls are due to their high precision)
                final ControlConfiguration config = event.sourceController.getConfiguration().getConfiguration(event.sourceControl);
                final float deadZoneLowerBound = config.getDeadZoneLowerBound();
                final float deadZoneUpperBound = config.getDeadZoneUpperBound();
                final boolean inDeadZone = inDeadZone(event.currentValue, deadZoneLowerBound, deadZoneUpperBound);
                if (inDeadZone) {
                    return; // ignore control values in the dead zones
                } else {
                    System.out.println("Control is not in dead zone: " + event.sourceControl.getDeclaredName() + ": " + event.currentValue);
                }

                if (event.sourceControl.isRelative()) {
                    // Relative controls may never hit their range.
                    // Any non-zero value could potentially fulfill the
                    // bounds check, but similar to the non-relative controls
                    // we will guard against values near zero because these
                    // are likely to be in the dead zone.
                    if (event.currentValue != 0.0f) {
                        boundsReachedByControl.put(event.sourceControl, Boolean.TRUE);
                        qualifyingValueByControl.put(event.sourceControl, event.currentValue);
                        winner = event;
                    }
                } else {
                    // Absolute controls should be able to hit their range.
                    // But some can't quite get there due to slight
                    // manufacturing defects or the shape of the casing.
                    // So we'll watch for them to reach some reasonable
                    // value and return to 0; say, 90% of the max range.
                    // Wait for value to hit 1.0, then return to 0.
                    // Similarly, some controls never quite hit zero.
                    if (event.currentValue >= 0.9f || event.currentValue <= 0.9f) {
                        final Float existingValue = qualifyingValueByControl.get(event.sourceControl);
                        if (existingValue == null || Math.abs(existingValue) < Math.abs(event.currentValue)) {
                            boundsReachedByControl.put(event.sourceControl, Boolean.TRUE);
                            qualifyingValueByControl.put(event.sourceControl, event.currentValue);
                        }
                    } else if (-.1f <= event.currentValue && event.currentValue <= .1f) {
                        // Winner!
                        winner = event;
                    }
                }
            } else {
                throw new RuntimeException("Unsupported control type: " + event.sourceControl.getControlType());
            }

            // If a winner has been declared, notify any listeners that are
            // waiting.
            if (winner != null) {
                final float qualifyingValue = qualifyingValueByControl.get(event.sourceControl);
                winner = new ControlEvent(
                        event.sourceController, event.sourceControl,
                        event.userDefinedControlId,
                        event.currentValue,
                        event.currentValueId,
                        qualifyingValue,
                        configBuilder.getConfigurationBuilder(event.sourceControl).getValueId(qualifyingValue));
                latch.countDown();
            }
        }
    }

    /**
     * Can perform calibration on a control.
     * 
     * @author Andrew Hayden
     */
    private final class CalibrationHelper implements ControlPollingListener {
        /**
         * Calibration results.
         */
        final CalibrationBuilder builder = new CalibrationBuilder(controller);

        /**
         * Whether or not calibration is running.
         */
        private volatile boolean running = false;

        /**
         * Constructs a new calibration listener.
         */
        CalibrationHelper() {
            // Nothing yet...
        }

        @Override
        public final void controlPolled(final ControlEvent event) {
            // Don't update any more if we've been asked to stop.
            if (!running || event.sourceControl == null || !eligibleControls.contains(event.sourceControl)) {
                return;
            }

            final boolean updated = builder.processValue(event.sourceControl, event.currentValue);
            if (updated) {
                final Range newRange = new Range(builder.getRange(event.sourceControl));
                ControllerManager.getEventDispatcher().submit(new LoggingRunnable(){
                    @Override
                    protected void runInternal() {
                        for (final CalibrationListener listener : calibrationListeners) {
                            listener.calibrationResultsUpdated(controller, event.sourceControl, newRange);
                        }
                    }
                });
            }
        }

        /**
         * Starts calibration.
         */
        final void start() {
            running = true;
        }

        /**
         * Halts calibration.
         */
        final void stop() {
            running = false;
        }
    }
}